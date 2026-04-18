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

setwd("~/Desktop/GitHub/technical-interview-april-2026/question_4_tlg")

# Import the data.frame
adae <- pharmaverseadam::adae

adae %>%
  filter(TRTEMFL %in% "Y") %>%
  dplyr::select(USUBJID, ACTARM, AETERM, AESEV, AEREL, AESTDTC, AEENDTC) %>%
  arrange(USUBJID, AESTDTC) %>%
  tbl_listing() %>%
  as_gt() %>% 
  gt::gtsave(filename = "ae_listings.html")
  
  
  
