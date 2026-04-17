library(sdtm.oak)
library(pharmaverseraw)
library(pharmaversesdtm)
library(dplyr)
library(lubridate)

# Input raw data
ds_raw <- pharmaverseraw::ds_raw

# Read the dm domain
dm <- pharmaversesdtm::dm

# Create study_ct data frame
# study_ct <-
#   data.frame(
#     stringsAsFactors = FALSE,
#     codelist_code = c("C66727", "C66727", "C66727", "C66727", "C66727", 
#                       "C66727", "C66727", "C66727", "C66727", "C66727"),
#     term_code = c("C41331", "C25250", "C28554", "C48226", "C48227", "C48250",
#                   "C142185", "C49628", "C49632", "C49634"),
#     term_value = c("ADVERSE EVENT", "COMPLETED", "DEATH", "LACK OF EFFICACY", "LOST TO FOLLOW-UP",
#                    "PHYSICIAN DECISION", "PROTOCOL VIOLATION", "SCREEN FAILURE",
#                    "STUDY TERMINATED BY SPONSOR", "WITHDRAWAL BY SUBJECT"),
#     collected_value = c("Adverse Event", "Complete", "Dead", "Lack of Efficacy", "Lost To Follow-Up",
#                         "Physician Decision", "Protocol Violation", "Trial Screen Failure",
#                         "Study Terminated By Sponsor", "Withdrawal by Subject"),
#     term_preferred_term = c("AE", "Completed", "Died", NA, NA, NA, "Violation",
#                             "Failure to Meet Inclusion/Exclusion Criteria", NA, "Dropout"),
#     term_synonyms = c("ADVERSE EVENT", "COMPLETE", "Death", NA, NA, NA, NA, NA, NA,
#                       "Discontinued Participation"))

study_ct <- read.csv(system.file("raw_data/sdtm_ct.csv",
                                 package = "sdtm.oak"))

# Create oak_id_vars
ds_raw <- ds_raw %>%
  generate_oak_id_vars(pat_var = "PATNUM",
                       raw_src = "ds_raw")

# Derive topic variable
ds <-
  # Map DSTERM using assign_no_ct, raw_var=IT.DSTERM, tgt_var=DSTERM
  assign_no_ct(
    raw_dat = condition_add(ds_raw, is.na(OTHERSP)),
    raw_var = "IT.DSTERM",
    tgt_var = "DSTERM",
    id_vars = oak_id_vars()
  )

# Map the rest of the variables
ds <- ds %>%
  # Map DSDECOD when OTHERSP is NA using assign_no_ct
  assign_no_ct(
    raw_dat = condition_add(ds_raw, is.na(OTHERSP)),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSDECOD",
    id_vars = oak_id_vars()
  ) %>%
  # Map DSCAT when IT.DSDECOD == "Randomized" using hardcode_no_ct
  hardcode_no_ct(
    raw_dat = condition_add(ds_raw, IT.DSDECOD == "Randomized"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    tgt_val = "PROTOCOL MILESTONE",
    id_vars = oak_id_vars()
  ) %>%
  # Map DSCAT when IT.DSDECOD != "Randomized" using hardcode_no_ct
  hardcode_no_ct(
    raw_dat = condition_add(ds_raw, IT.DSDECOD != "Randomized"),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    tgt_val = "DISPOSITION EVENT",
    id_vars = oak_id_vars()
  ) %>%
  assign_no_ct(
    # Map DSDECOD when OTHERSP is not NA using assign_no_ct
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSDECOD",
    id_vars = oak_id_vars()
  ) %>%
  assign_no_ct(
    # Map DSTERM when OTHERSP is not NA using assign_no_ct
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSTERM",
    id_vars = oak_id_vars()
  ) %>%
  hardcode_no_ct(
    # Map DSCAT when OTHERSP is not NA using hardcode_no_ct
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSCAT",
    tgt_val = "OTHER EVENT",
    id_vars = oak_id_vars()
  ) %>%
  assign_no_ct(
    # Map DSSTDTC using assign_no_ct
    raw_dat = ds_raw,
    raw_var = "IT.DSSTDAT",
    tgt_var = "DSSTDTC",
    id_vars = oak_id_vars()
  ) %>%
  # Map VISIT from INSTANCE using assign_ct
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISIT",
    ct_spec = study_ct,
    ct_clst = "VISIT",
    id_vars = oak_id_vars()
  ) %>%
  # Map VISITNUM from INSTANCE using assign_ct
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISITNUM",
    ct_spec = study_ct,
    ct_clst = "VISITNUM",
    id_vars = oak_id_vars()
  )

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
    DSDTC = if_else(is.na(DSTMCOL),
      format_ISO8601(as.Date(DSDTCOL, "%m-%d-%Y")),
      format_ISO8601(strptime(paste(DSDTCOL, DSTMCOL), format = "%m-%d-%Y %H:%M"), precision = "ymdhm")),
    DSSTDTC = format_ISO8601(as.Date(DSSTDTC, format = "%m-%d-%Y")),
  ) %>%
  derive_seq(
    tgt_var = "DSSEQ",
    rec_vars = c("USUBJID", "DSTERM")
  ) %>%
  derive_study_day(
    sdtm_in = .,
    dm_domain = dm,
    tgdt = "DSSTDTC",
    refdt = "RFXSTDTC",
    study_day_var = "DSSTDY"
  ) %>%
  dplyr::select("STUDYID", "DOMAIN", "USUBJID", "DSSEQ", "DSTERM", "DSDECOD", "DSCAT", "VISITNUM",
                "VISIT", "DSDTC", "DSSTDTC", "DSSTDY")
