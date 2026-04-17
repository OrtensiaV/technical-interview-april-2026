# ============================================================================
# Question 2: SDTM DS Domain Creation using {sdtm.oak}
# ============================================================================
#
# Create SDTM Disposition (DS) domain dataset from raw clinical data
#
# Author: Ortensia Vito
# ============================================================================

# Load required packages
library(sdtm.oak)
library(pharmaverseraw)
library(pharmaversesdtm)
library(dplyr)
library(lubridate)

# Load raw disposition data
ds_raw <- pharmaverseraw::ds_raw

# Load demographics domain for reference date derivation
dm <- pharmaversesdtm::dm

# Load controlled terminology specification
study_ct <- read.csv(system.file("raw_data/sdtm_ct.csv",
                                 package = "sdtm.oak"))

# Generate unique record identifiers
ds_raw <- ds_raw %>%
  generate_oak_id_vars(pat_var = "PATNUM",
                       raw_src = "ds_raw")

# Map disposition term when other specification is null
ds <-
  assign_no_ct(
    raw_dat = condition_add(ds_raw, is.na(OTHERSP)),
    raw_var = "IT.DSTERM",
    tgt_var = "DSTERM",
    id_vars = oak_id_vars()
  )

# Map disposition decode and category variables
ds <- ds %>%
  # Map disposition decode when other specification is null
  assign_no_ct(
    raw_dat = condition_add(ds_raw, is.na(OTHERSP)),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSDECOD",
    id_vars = oak_id_vars()
  ) %>%
  # Assign protocol milestone category for randomisation events
  hardcode_no_ct(
    raw_dat = condition_add(ds_raw, IT.DSDECOD == "Randomized"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    tgt_val = "PROTOCOL MILESTONE",
    id_vars = oak_id_vars()
  ) %>%
  # Assign disposition event category for non-randomisation events
  hardcode_no_ct(
    raw_dat = condition_add(ds_raw, IT.DSDECOD != "Randomized"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    tgt_val = "DISPOSITION EVENT",
    id_vars = oak_id_vars()
  ) %>%
  # Map disposition decode when other specification is present
  assign_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSDECOD",
    id_vars = oak_id_vars()
  ) %>%
  # Map disposition term when other specification is present
  assign_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSTERM",
    id_vars = oak_id_vars()
  ) %>%
  # Assign other event category when other specification is present
  hardcode_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSCAT",
    tgt_val = "OTHER EVENT",
    id_vars = oak_id_vars()
  ) %>%
  # Map disposition start date
  assign_no_ct(
    raw_dat = ds_raw,
    raw_var = "IT.DSSTDAT",
    tgt_var = "DSSTDTC",
    id_vars = oak_id_vars()
  ) %>%
  # Map visit name using controlled terminology
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISIT",
    ct_spec = study_ct,
    ct_clst = "VISIT",
    id_vars = oak_id_vars()
  ) %>%
  # Map visit number using controlled terminology
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISITNUM",
    ct_spec = study_ct,
    ct_clst = "VISITNUM",
    id_vars = oak_id_vars()
  )

# Finalise DS domain with derived variables
ds <- ds %>%
  dplyr::mutate(
    STUDYID = ds_raw$STUDY,
    DOMAIN = "DS",
    USUBJID = paste("01-", ds_raw$PATNUM, sep = ""),
    DSTERM = toupper(DSTERM),
    DSDECOD = toupper(DSDECOD),
    DSCAT = toupper(DSCAT),
    VISITNUM = VISITNUM,
    VISIT = VISIT,
    DSDTCOL = as.character(ds_raw$DSDTCOL),
    DSTMCOL = as.character(ds_raw$DSTMCOL),
    # Combine date and time into ISO8601 format
    DSDTC = if_else(is.na(DSTMCOL),
                    format_ISO8601(as.Date(DSDTCOL, "%m-%d-%Y")),
                    format_ISO8601(strptime(paste(DSDTCOL, DSTMCOL), format = "%m-%d-%Y %H:%M"), precision = "ymdhm")),
    DSSTDTC = format_ISO8601(as.Date(DSSTDTC, format = "%m-%d-%Y")),
  ) %>%
  # Derive sequence number per subject
  derive_seq(
    tgt_var = "DSSEQ",
    rec_vars = c("USUBJID", "DSTERM")
  ) %>%
  # Calculate study day relative to reference start date
  derive_study_day(
    sdtm_in = .,
    dm_domain = dm,
    tgdt = "DSSTDTC",
    refdt = "RFXSTDTC",
    study_day_var = "DSSTDY"
  ) %>%
  # Select final SDTM variables
  dplyr::select("STUDYID", "DOMAIN", "USUBJID", "DSSEQ", "DSTERM", "DSDECOD", "DSCAT", "VISITNUM",
                "VISIT", "DSDTC", "DSSTDTC", "DSSTDY")