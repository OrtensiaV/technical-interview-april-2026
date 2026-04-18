# ============================================================================
# Question 4: TLG - Adverse Event Reporting (Script 1)
# ============================================================================
#
# Creat a summary table of treatment-emergent adverse events (TEAEs)
#
# Author: Ortensia Vito
# ============================================================================

setwd("~/Desktop/GitHub/technical-interview-april-2026/question_4_tlg")

# Load required packages
library(dplyr)
library(pharmaverseadam)
library(gtsummary)

adae <- pharmaverseadam::adae
adsl <- pharmaverseadam::adsl

# Filter for treatment-emergent adverse events
adae <- adae %>%
  filter(TRTEMFL == "Y")

# Create the summary table and save .html file           
tbl_aesoc <- adae %>%
  tbl_hierarchical(
    variables = c(AESOC, AEDECOD),
    by = ACTARM,
    id = USUBJID,
    denominator = adsl,
    overall_row = TRUE,
    label = "..ard_hierarchical_overall.." ~ "Any SAE"
  ) %>%
  as_gt() %>% 
  gt::gtsave(filename = "tbl_aesoc.html")

