# ============================================================================
# Question 4: TLG - Adverse Event Reporting (Script 3)
# ============================================================================
#
# Listing using {gtsummary}
#
# Author: Ortensia Vito
# ============================================================================

# Load required packages
library(dplyr)
library(pharmaverseadam)
library(gtsummary)
library(gtreg)
library(gt)

setwd("~/Desktop/GitHub/technical-interview-april-2026/question_4_tlg")

# Import the data.frame
adae <- pharmaverseadam::adae

adae %>%
  filter(TRTEMFL %in% "Y") %>%
  arrange(USUBJID, AESTDTC) %>%
  group_by(USUBJID) %>%
  mutate(
    USUBJID_DISPLAY = if_else(row_number() == 1, as.character(USUBJID), ""),
    ACTARM_DISPLAY = if_else(row_number() == 1, as.character(ACTARM), "")
  ) %>%
  ungroup() %>%
  mutate(
    USUBJID_DISPLAY = structure(USUBJID_DISPLAY, label = attr(USUBJID, "label")),
    ACTARM_DISPLAY = structure(ACTARM_DISPLAY, label = attr(ACTARM, "label"))
  ) %>%
  dplyr::select(USUBJID_DISPLAY, ACTARM_DISPLAY, AETERM, AESEV, AEREL, AESTDTC, AEENDTC) %>%
  tbl_listing() %>%
  as_gt() %>%
  gt::tab_options(
    table_body.hlines.style = "none"
  ) %>%
  gt::gtsave(filename = "ae_listings.html")
  
  
