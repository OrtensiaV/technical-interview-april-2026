# ============================================================================
# Question 1: Descriptive Statistics R Package Development
# ============================================================================
#
# This script documents the complete workflow for creating the descriptiveStats
# package, including setup, development, testing, and validation.
#
# Author: Ortensia Vito
# ============================================================================

# SECTION 1: ENVIRONMENT SETUP -----------------------------------------------

# Install required packages if not already installed
required_packages <- c("devtools", "usethis", "roxygen2", "testthat")

for (pkg in required_packages) {
  if (!require(pkg, character.only = TRUE)) {
    install.packages(pkg)
    library(pkg, character.only = TRUE)
  }
}

# Set working directory to repository root
setwd("~/Desktop/GitHub/technical-interview-april-2026/question_1")

# Verify working directory
getwd()

# SECTION 2: PACKAGE CREATION ------------------------------------------------

# Create parent directory for Question 1
dir.create("question_1", showWarnings = FALSE)

# Create the package structure
# This opens a new RStudio session - continue working there
usethis::create_package("question_1/descriptiveStats")

# Note: The following commands should be run in the NEW RStudio session
# that opens in the package directory

# SECTION 3: PACKAGE CONFIGURATION -------------------------------------------

# The DESCRIPTION file is automatically created
# I have edited it manually as below
# 
# Package: descriptiveStats
# Type: Package
# Title: Descriptive Statistics Functions
# Version: 0.1.0
# Authors@R: 
#   person("Ortensia", "Vito", , "ortensia_90@hotmail.it", role = c("aut", "cre"))
# Description: Provides functions for calculating common descriptive statistics
# including mean, median, mode, quartiles, and interquartile range. Handles
# edge cases and missing values appropriately.
# License: `use_mit_license()`
# Encoding: UTF-8
# Roxygen: list(markdown = TRUE)
# RoxygenNote: 7.3.2
# Suggests: 
#   testthat (>= 3.0.0)
# Config/testthat/edition: 3
# 

# SECTION 4: FUNCTION DEVELOPMENT ---------------------------------------------

# Create R functions file
usethis::use_r("descriptive_functions")

# The file R/descriptive_functions.R is created
# I have modified it manually including the following functions:
# - calc_mean()
# - calc_median()
# - calc_mode()
# - calc_q1()
# - calc_q3()
# - calc_iqr()

# SECTION 5: DOCUMENTATION GENERATION -----------------------------------------

# Generate documentation from Roxygen2 comments
# This creates .Rd files in man/ and updates NAMESPACE
devtools::document()

# Verify documentation was created
list.files("man/")

# SECTION 6: TESTING SETUP ----------------------------------------------------

# Set up testing infrastructure
usethis::use_testthat()

# Create test file for descriptive functions
usethis::use_test("descriptive_functions")

# The file tests/testthat/test-descriptive_functions.R is created
# Add test cases to this file (see separate file for complete tests)

# SECTION 7: RUN TESTS --------------------------------------------------------

# Run all tests
devtools::test()

# ℹ Testing descriptiveStats
# ✔ | F W  S  OK | Context
# ✔ |         59 | descriptive_functions                                                                                
# 
# ══ Results ═══════════════════════════════════════════════════════════════════════════════════════════════════════════
# [ FAIL 0 | WARN 0 | SKIP 0 | PASS 59 ]

# Update the licence
usethis::use_mit_license("Ortensia Vito")

# SECTION 8: PACKAGE VALIDATION -----------------------------------------------

# Comprehensive package check
# This validates structure, documentation, examples, and code quality
devtools::check()

# Results 
# ── R CMD check results ─────────────────────────────────────────────────────────────────── descriptiveStats 0.1.0 ────
# Duration: 9.6s
# 
# ❯ checking for future file timestamps ... NOTE
# unable to verify current time
# 
# 0 errors ✔ | 0 warnings ✔ | 1 note ✖

# SECTION 9: PACKAGE README ---------------------------------------------------

# Create package README
usethis::use_readme_md()

# README.md file updated with package documentation

# SECTION 10: MANUAL TESTING --------------------------------------------------

# Load the package for interactive testing
devtools::load_all()

# Test with example data
data <- c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)

# Calculate all statistics
calc_mean(data)      # Expected: 4.3
calc_median(data)    # Expected: 4.5
calc_mode(data)      # Expected: 5
calc_q1(data)        # Expected: 2
calc_q3(data)        # Expected: 5
calc_iqr(data)       # Expected: 3

# Test edge cases
calc_mean(c())                    # Warning: Empty vector
calc_mean(c(NA, NA, NA))          # Warning: No non-NA values
calc_mode(c(1, 2, 3, 4, 5))       # Warning: No mode exists
calc_mode(c(1, 1, 2, 2, 3))       # Message: Multiple modes

# Test NA handling
data_with_na <- c(1, 2, NA, 4, 5)
calc_mean(data_with_na, na.rm = TRUE)    # Expected: 3
calc_median(data_with_na, na.rm = FALSE) # Expected: NA

# Test error handling
tryCatch(
  calc_mean("text"),
  error = function(e) print(paste("Expected error:", e$message))
)

# SECTION 11: INSTALLATION TEST -----------------------------------------------

# Install the package locally
devtools::install()

# Load installed package
library(descriptiveStats)

# Verify functions are accessible
ls("package:descriptiveStats")

# Access documentation
?calc_mean
?calc_median

# SECTION 12: PACKAGE BUILD ---------------------------------------------------

# Build source package (creates .tar.gz file)
devtools::build()

# Build binary package
devtools::build(binary = TRUE)

# SECTION 13: FINAL VERIFICATION ----------------------------------------------

# Run final comprehensive check
devtools::check()

# SECTION 14: VERSION CONTROL -------------------------------------------------

# Return to main repository project to commit changes
# Switch to the main RStudio session (r-statistics-assessment project)

# In the main project, stage and commit all files:
# git add question_1/descriptiveStats/
# git commit -m "Complete Question 1: Descriptive Statistics Package"
# git push
