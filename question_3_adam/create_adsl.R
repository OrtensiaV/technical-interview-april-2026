# ============================================================================
# Question 3: ADaM ADSL Dataset Creation
# ============================================================================
#
# Create an ADSL dataset using SDTM source data, the {admiral} family of
# packages, and tidyverse tools.
#
# Author: Ortensia Vito
# ============================================================================

# Load Required Packages 
library(dplyr)              
library(admiral)            
library(pharmaverseraw)    
library(pharmaversesdtm)  
library(lubridate)       
library(stringr)      

# Load Input Datasets
# Read SDTM domains from pharmaversesdtm package
dm <- pharmaversesdtm::dm   # Demographics
vs <- pharmaversesdtm::vs   # Vital Signs
ex <- pharmaversesdtm::ex   # Exposure
ds <- pharmaversesdtm::ds   # Disposition
ae <- pharmaversesdtm::ae   # Adverse Events

# Convert Blank Values to NA 
# Replace empty strings with NA for proper missing value handling
dm <- convert_blanks_to_na(dm)
vs <- convert_blanks_to_na(vs)
ex <- convert_blanks_to_na(ex)
ds <- convert_blanks_to_na(ds)
ae <- convert_blanks_to_na(ae)

# Initialize ADSL Dataset
# Remove DOMAIN variable as it's not needed in ADSL
adsl <- dm %>%
  select(-DOMAIN)

# Derive AGEGR9 & AGEGR9N 
# Age grouping into categories: "<18", "18-50", ">50"
# AGEGR9: Character age group
# AGEGR9N: Numeric age group (1, 2, 3, 4 for missing)

# Define age grouping lookup table
agegr1_lookup <- exprs(
  ~condition,            ~AGEGR1, ~AGEGR1N,
  is.na(AGE),          "Missing",        4,  # Missing age
  AGE < 18,                "<18",        1,  # Paediatric
  between(AGE, 18, 50),  "18-50",        2,  # Adult
  !is.na(AGE),             ">50",        3   # Elderly (catch-all for remaining)
)

# Apply age grouping derivation
adsl <- derive_vars_cat(
  dataset = adsl,
  definition = agegr1_lookup
)

# Derive TRTSDTM, TRTSTMF, TRTEDTM, TRTETMF
# Treatment start and end date-times from exposure records
# Valid dose defined as: EXDOSE > 0 OR (EXDOSE = 0 AND EXTRT contains "PLACEBO")
# Impute missing hours and minutes with 00, but not seconds
# Flag imputation in TRTSTMF and TRTETMF

# Convert exposure dates to date-times with imputation
ex_ext <- ex %>%
  # Derive exposure start date-time
  derive_vars_dtm(
    dtc = EXSTDTC,                    # Source date-time character variable
    new_vars_prefix = "EXST",         # Creates EXSTDTM and EXSTTMF
    highest_imputation = "M"          # Impute up to minutes, not seconds
  ) %>%
  # Derive exposure end date-time
  derive_vars_dtm(
    dtc = EXENDTC,                    # Source date-time character variable
    new_vars_prefix = "EXEN",         # Creates EXENDTM and EXENTMF
    highest_imputation = "M",         # Impute up to minutes, not seconds
    time_imputation = "last"          # Impute end time to last moment (23:59:00)
  )

# Merge first valid exposure to get treatment start
adsl <- adsl %>%
  derive_vars_merged(
    dataset_add = ex_ext,
    # Filter for valid doses with non-missing start date-time
    filter_add = (EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO"))) & 
      !is.na(EXSTDTM),
    # Variables to merge from exposure
    new_vars = exprs(TRTSDTM = EXSTDTM, TRTSTMF = EXSTTMF),
    # Order by date-time and sequence to get first exposure
    order = exprs(EXSTDTM, EXSEQ),
    mode = "first",                   # Take first exposure record
    by_vars = exprs(STUDYID, USUBJID) # Merge keys
  ) %>%
  # Merge last valid exposure to get treatment end
  derive_vars_merged(
    dataset_add = ex_ext,
    # Filter for valid doses with non-missing end date-time
    filter_add = (EXDOSE > 0 | (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO"))) & 
      !is.na(EXENDTM),
    # Variables to merge from exposure
    new_vars = exprs(TRTEDTM = EXENDTM, TRTETMF = EXENTMF),
    # Order by date-time and sequence to get last exposure
    order = exprs(EXENDTM, EXSEQ),
    mode = "last",                    # Take last exposure record
    by_vars = exprs(STUDYID, USUBJID) # Merge keys
  ) %>%
  # Convert date-times to dates (TRTSDTM -> TRTSDT, TRTEDTM -> TRTEDT)
  derive_vars_dtm_to_dt(source_vars = exprs(TRTSDTM, TRTEDTM)) %>%
  # Extract time component from treatment start date-time (TRTSDTM -> TRTSDTM time)
  derive_vars_dtm_to_tm(source_vars = exprs(TRTSDTM)) %>%
  # Calculate treatment duration (TRTEDT - TRTSDT + 1)
  derive_var_trtdurd()

# Derive ITTFL 
# Intent-to-Treat Flag: "Y" if patient was randomised (ARM populated), "N" otherwise
adsl <- adsl %>%
  mutate(ITTFL = case_when(
    !is.na(ARM) ~ "Y",  # Randomised patients
    .default = "N"      # Non-randomised patients
  ))

# Derive ABNSBPFL 
# Abnormal Systolic Blood Pressure Flag
# "Y" if patient has ANY systolic BP <100 or >=140 mmHg, "N" otherwise

# Calculate min and max systolic BP per patient
abnsbp <- vs %>%
  filter(
    VSTESTCD == "SYSBP",    # Systolic blood pressure test
    VSSTRESU == "mmHg",     # Unit must be mmHg
    !is.na(VSSTRESN)        # Valid numeric result
  ) %>%
  group_by(USUBJID) %>%
  summarise(
    max_sysbp = max(VSSTRESN, na.rm = TRUE),  # Maximum BP across all visits
    min_sysbp = min(VSSTRESN, na.rm = TRUE),  # Minimum BP across all visits
    .groups = "drop"
  ) %>%
  # Flag as abnormal if any measurement is outside normal range
  mutate(
    ABNSBPFL = if_else(max_sysbp >= 140 | min_sysbp < 100, "Y", "N")
  ) %>%
  select(USUBJID, ABNSBPFL)

# Merge abnormal BP flag to ADSL
adsl <- adsl %>%
  left_join(abnsbp, by = "USUBJID")

# Derive LSTALVDT 
# Last Known Alive Date
# Maximum date across: vital signs, adverse events, disposition, and treatment
# Only complete dates (no imputation) are used

# First, derive treatment end date from treatment end date-time
adsl <- adsl %>%
  mutate(TRTEDT = if_else(!is.na(TRTEDTM), as.Date(TRTEDTM), NA_Date_))

# Use extreme event derivation to find maximum date across all sources
adsl <- adsl %>%
  derive_vars_extreme_event(
    by_vars = exprs(STUDYID, USUBJID),
    events = list(
      # Event 1: Last complete vital signs date with valid test result
      # Valid if at least one of VSSTRESN or VSSTRESC is not missing
      event(
        dataset_name = "vs",
        order = exprs(VSDTC, VSSEQ),  # Order by date and sequence
        condition = !is.na(VSDTC) & !(is.na(VSSTRESN) & is.na(VSSTRESC)),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(VSDTC, highest_imputation = "n"),  # No imputation
          seq = VSSEQ
        )
      ),
      # Event 2: Last complete adverse event onset date
      event(
        dataset_name = "ae",
        order = exprs(AESTDTC, AESEQ),  # Order by date and sequence
        condition = !is.na(AESTDTC),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(AESTDTC, highest_imputation = "n"),  # No imputation
          seq = AESEQ
        )
      ),
      # Event 3: Last complete disposition date
      event(
        dataset_name = "ds",
        order = exprs(DSSTDTC, DSSEQ),  # Order by date and sequence
        condition = !is.na(DSSTDTC),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(DSSTDTC, highest_imputation = "n"),  # No imputation
          seq = DSSEQ
        )
      ),
      # Event 4: Last treatment date (already derived as TRTEDT)
      event(
        dataset_name = "adsl",
        condition = !is.na(TRTEDT),
        set_values_to = exprs(
          LSTALVDT = TRTEDT,
          seq = 0  # Sequence 0 for ADSL source
        )
      )
    ),
    # Provide source datasets for event derivation
    source_datasets = list(
      vs = vs,
      ae = ae,
      ds = ds,
      adsl = adsl
    ),
    tmp_event_nr_var = event_nr,  # Temporary variable for event numbering
    order = exprs(LSTALVDT, seq, event_nr),  # Order to select maximum date
    mode = "last",  # Select the last (maximum) date across all sources
    new_vars = exprs(LSTALVDT)
  )

# Derive CARPOPFL
# Cardiac Population Flag
# "Y" if patient has any adverse event in "CARDIAC DISORDERS" system organ class
# NA otherwise (not "N")

adsl <- adsl %>%
  derive_var_merged_exist_flag(
    dataset_add = ae,
    by_vars = exprs(STUDYID, USUBJID),  # Merge keys
    new_var = CARPOPFL,
    condition = toupper(AESOC) == "CARDIAC DISORDERS"  # Case-insensitive match
  )
