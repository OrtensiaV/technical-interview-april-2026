# Clinical Programming Assessment Portfolio

Comprehensive solutions demonstrating clinical data programming expertise across R and Python ecosystems, covering regulatory standards, data engineering, and modern AI applications.

## Overview

This repository contains solutions to six technical questions spanning:

- **R Package Development**: Custom statistical functions with full documentation
- **CDISC Standards**: SDTM and ADaM dataset creation using Pharmaverse
- **Regulatory Reporting**: Tables, Listings, and Graphs (TLGs) for clinical trials
- **API Development**: RESTful clinical data services with FastAPI
- **GenAI Applications**: LLM-powered clinical data assistant using LangChain

## Repository Structure

```
├── question_1/    # Descriptive Statistics R Package
├── question_2/    # SDTM DS Domain Creation (sdtm.oak)
├── question_3/    # ADaM ADSL Dataset Creation
├── question_4/    # Adverse Events TLG Reporting
├── question_5/    # Clinical Data API (FastAPI)
├── question_6/    # GenAI Clinical Data Assistant (LangChain)
└── README.md
```
## Author

Ortensia Vito

## Question 1: Descriptive Statistics R Package

**Location**: `question_1/descriptive_stats/`

A complete R package implementing descriptive statistics functions with robust error handling and comprehensive documentation.

### Features
- Six core functions: mean, median, mode, Q1, Q3, IQR
- Full Roxygen2 documentation
- Comprehensive test suite using testthat
- Handles edge cases (empty vectors, NA values, ties)

### Installation

```r
devtools::install("question_1/descriptive_stats")
library(descriptiveStats)
```

### Usage

```r
data <- c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)
calc_mean(data)    # 4.3
calc_median(data)  # 4.5
calc_mode(data)    # 5
```

See `question_1/descriptive_stats/README.md` for detailed documentation.

## Question 2: SDTM DS Domain Creation

**Location**: `question_2_stdm/02_create_ds_domain.R`

### Objective

Create an SDTM Disposition (DS) domain dataset from raw clinical trial data using the `{sdtm.oak}` package.

### Approach

The DS domain captures subject disposition events throughout the clinical trial, including protocol milestones (e.g., randomisation) and disposition events (e.g., completion, withdrawal). The implementation follows CDISC SDTM standards and applies conditional logic based on aCRF specifications.

### Key Features

- **Conditional Mapping Logic**: Implements business rules for DSTERM, DSDECOD, and DSCAT based on the presence of other specifications (OTHERSP)
- **Controlled Terminology**: Applies CT mappings for visit variables (VISIT, VISITNUM) using the study CT specification
- **Date Handling**: Converts raw dates and times to ISO8601 format, combining date of collection (DSDTCOL) and time of collection (DSTMCOL) into DSDTC
- **Study Day Derivation**: Calculates DSSTDY relative to the reference start date from the DM domain
- **Sequence Generation**: Derives DSSEQ per subject based on USUBJID and DSTERM

### Implementation Details

The script utilises `{sdtm.oak}` functions including:

- `assign_no_ct()`: Direct variable assignments without controlled terminology
- `assign_ct()`: Variable assignments with controlled terminology mappings
- `hardcode_no_ct()`: Hardcoded value assignments for categorical variables
- `condition_add()`: Conditional filtering of raw data based on business rules
- `derive_seq()`: Sequence number derivation
- `derive_study_day()`: Study day calculation relative to reference dates

### Business Rules Applied

1. When OTHERSP is null, map IT.DSTERM to DSTERM and IT.DSDECOD to DSDECOD
2. When OTHERSP is not null, map OTHERSP to both DSTERM and DSDECOD
3. When IT.DSDECOD equals "Randomized", assign DSCAT as "PROTOCOL MILESTONE"
4. When IT.DSDECOD does not equal "Randomized" and OTHERSP is null, assign DSCAT as "DISPOSITION EVENT"
5. When OTHERSP is not null, assign DSCAT as "OTHER EVENT"

### Output Variables

The final DS domain contains the following SDTM variables:

STUDYID, DOMAIN, USUBJID, DSSEQ, DSTERM, DSDECOD, DSCAT, VISITNUM, VISIT, DSDTC, DSSTDTC, DSSTDY

### Data Sources

- **Raw Data**: `pharmaverseraw::ds_raw`
- **Reference Domain**: `pharmaversesdtm::dm` (for study day derivation)
- **Controlled Terminology**: `"raw_data/sdtm_ct.csv"` from `{sdtm.oak}` package

## Question 3: ADaM ADSL Dataset Creation

**Location**: `question_3_adam/create_adsl.R`

Creation of Analysis Data Model (ADaM) Subject-Level Analysis Dataset (ADSL).

## Overview

This project creates an Analysis Dataset Subject Level (ADSL) from SDTM source data using the {admiral} family of packages and tidyverse tools, following Pharmaverse standards and CDISC ADaM guidelines.

## Purpose

The ADSL dataset contains one record per subject with key demographic, treatment, and derived variables used across multiple analyses.

## Data Sources

The programme uses the following SDTM domains from the `pharmaversesdtm` package:

- **DM** (Demographics): Base dataset for subject-level information
- **EX** (Exposure): Treatment administration records
- **VS** (Vital Signs): Blood pressure measurements
- **AE** (Adverse Events): Adverse event records
- **DS** (Disposition): Study disposition events

## Key Derived Variables

### AGEGR9 & AGEGR9N
Age grouping variables categorising subjects into:
- `"<18"` 
- `"18-50"`
- `">50"` 

AGEGR9N provides numeric equivalents (1, 2, 3).

### TRTSDTM & TRTSTMF
Treatment start date-time derived from the first valid exposure record. Missing time components are imputed to 00:00:00 for hours and minutes (but not seconds). The imputation flag (TRTSTMF) indicates which time components were imputed.

**Valid dose criteria**: EXDOSE > 0 OR (EXDOSE = 0 AND EXTRT contains "PLACEBO")

### TRTEDTM & TRTETMF
Treatment end date-time derived from the last valid exposure record, with similar imputation logic to TRTSDTM.

### ITTFL
Intent-to-Treat Flag indicating whether a subject was randomised:
- `"Y"`: Subject has a populated ARM value
- `"N"`: Subject was not randomised

### ABNSBPFL
Abnormal Systolic Blood Pressure Flag identifying subjects with any systolic BP measurement <100 or ≥140 mmHg:
- `"Y"`: At least one abnormal measurement
- `"N"`: All measurements within normal range

### LSTALVDT
Last Known Alive Date representing the maximum date across four sources:
1. Last vital signs assessment with valid results
2. Last adverse event onset date
3. Last disposition event date
4. Last treatment administration date

Only complete dates (no imputation) are included in this derivation.

### CARPOPFL
Cardiac Population Flag identifying subjects with cardiac adverse events:
- `"Y"`: Subject has at least one AE in "CARDIAC DISORDERS" system organ class
- `NA`: No cardiac adverse events

## Technical Implementation and Execution

Run the main script:

```r
source("adsl_creation.R")
```

The script will:
1. Load and prepare SDTM source datasets
2. Derive all required ADSL variables
3. Output the final ADSL dataset

## Output

The final ADSL dataset contains all standard DM variables plus the derived variables listed above, ready for use in downstream analysis datasets and statistical analyses.

## Question 4: TLG - Adverse Events Reporting

**Location**: `question_4_tlg/`

# Question 4: TLG - Adverse Events Reporting

## Overview

This section creates Tables, Listings, and Graphs (TLGs) for adverse events summary using the `pharmaverseadam::adae` and `pharmaverseadam::adsl` datasets. 

## Objectives

- Generate a summary table of treatment-emergent adverse events (TEAEs) by system organ class
- Visualise adverse event severity distribution across treatment arms
- Identify and display the top 10 most frequent adverse events with confidence intervals
- Produce a detailed listing of all treatment-emergent adverse events

## Scripts

### 1. `01_create_ae_summary_table.R`

**Purpose**: Creates a hierarchical summary table of treatment-emergent adverse events organised by System Organ Class (SOC) and Adverse Event Decoded Term (AEDECOD).

**Key Features**:
- Filters for treatment-emergent events (`TRTEMFL == "Y"`)
- Displays event counts and percentages by treatment arm (`ACTARM`)
- Includes an overall summary row for any serious adverse event
- Uses subject-level denominators from `adsl` for accurate percentage calculations

**Output**: `ae_summary_table.html`

### 2. `02_create_visualizations.R`

**Purpose**: Generates two visualisations to support adverse event analysis.

**Plot 1 - AE Severity Distribution**:
- **Type**: Stacked bar chart
- **Variables**: Treatment arm (x-axis), count of AEs (y-axis), severity/intensity (fill)
- **Output**: `ae_severity_distribution_by_treatment.png`

**Plot 2 - Top 10 Most Frequent AEs**:
- **Type**: Forest plot with error bars
- **Variables**: Percentage of patients experiencing each AE with 95% confidence intervals
- **Calculation**: Uses binomial distribution for CI estimation (`qbinom`)
- **Sample Size**: 225 subjects
- **Output**: `top_10_aes.png`

### 3. `03_create_listings.R`

**Purpose**: Produces a detailed patient-level listing of all treatment-emergent adverse events.

**Included Variables**:
- Subject ID (`USUBJID`)
- Treatment arm (`ACTARM`)
- Adverse event term (`AETERM`)
- Severity (`AESEV`)
- Relationship to study drug (`AEREL`)
- Start and end dates (`AESTDTC`, `AEENDTC`)

**Sorting**: By subject ID and event start date

**Output**: `ae_listings.html`

## Dependencies

``` r
library(dplyr)
library(pharmaverseadam)
library(gtsummary)
library(gtreg)
library(ggplot2)
library(gt)
```

## Usage

Execute the scripts in numerical order:

``` r
source("question_4_tlg/01_create_ae_summary_table.R")
source("question_4_tlg/02_create_visualizations.R")
source("question_4_tlg/03_create_listings.R")
```

## Outputs

All output files are saved to the `question_4_tlg/` directory:

- `ae_summary_table.html` - Hierarchical summary table
- `ae_severity_distribution_by_treatment.png` - Severity distribution visualisation
- `top_10_aes.png` - Top 10 AEs with confidence intervals
- `ae_listings.html` - Detailed patient-level listing

## Question 5: Clinical Data API (FastAPI)

**Location**: `question_5/`

RESTful API for clinical data access and manipulation built with FastAPI.

# Clinical Data Analysis Project

This repository contains my solutions to a series of clinical data analysis exercises, working with adverse event data from clinical trials using the CDISC SDTM standard.

## What's Inside

The project covers five different tasks, each focusing on a different aspect of clinical data analysis - from data export and cleaning through to building a working API.

## Repository Structure

```bash
.
├── exercise5/                 # Task 5: Clinical Data API
  │   ├── main.py               # The main API application
│   ├── dev_test_code.py      # Testing and development code
│   ├── adae.csv              # Adverse event dataset
│   └── README.md             # Detailed API documentation
└── README.md                 # This file
```

## The Tasks

### Task 1: Data Export (R)
Exported the adverse events dataset from the `pharmaversesdtm` package to CSV format so I could use it in Python for the later tasks.

### Task 2: Data Cleaning and Transformation (Python/Pandas)
Cleaned up the adverse event data, filtered for severe events, and created summary statistics grouped by treatment arm.

### Task 3: Data Visualisation (Python/Matplotlib or Plotly)
Created visualisations to explore patterns in the data - looking at severity distributions across treatment groups, time-to-event analysis, and frequency by system organ class.

### Task 4: Statistical Analysis (Python/SciPy or Statsmodels)
Ran statistical tests to compare adverse event rates between treatment groups, including chi-square tests and survival analysis.

### Task 5: Clinical Data API (FastAPI)
Built a REST API with three endpoints:
  
1. **GET `/`** - Simple welcome message to confirm the API is running
2. **POST `/ae-query`** - Filter adverse events by severity and treatment arm
3. **GET `/subject-risk/{subject_id}`** - Calculate a safety risk score for individual patients

The API includes proper error handling and comes with interactive documentation through Swagger UI.

## What Each File Does

**main.py** is the production-ready API code - it's what you actually run to start the server.

**dev_test_code.py** contains all my test cases and development experiments. It's useful for checking everything works but isn't needed to run the API.

## Tech Stack

- **R** for initial data export
- **Python 3.8+** as the main language
- **Pandas** for data manipulation
- **FastAPI** for the REST API
- **Uvicorn** to run the server
- **Pydantic** for data validation

## Getting Started

### What You'll Need

- Python 3.8 or higher installed
- Git to clone the repository

### Setting Up

First, clone the repository and navigate to the API folder:
  
  ```bash
git clone https://github.com/OrtensiaV/technical-interview-april-2026
cd technical-interview-april-2026/question_5
```

Then install the required packages:
  
  ```bash
pip install fastapi uvicorn pandas pydantic
```

### Running the API

Start the server with:
  
  ```bash
uvicorn main:app --reload
```

You'll see some output confirming the server has started. The `--reload` flag means the server will automatically restart when you make changes to the code.

### Using the API

Once it's running, open your browser and go to:
  
- **`http://localhost:8000/docs`** for the interactive documentation (this is the easiest way to test it)
- **`http://localhost:8000/`** to see the welcome message

The interactive docs let you try out each endpoint directly in your browser - just click "Try it out", enter your parameters, and hit "Execute".

### Running the Tests

If you want to run all the test cases:
  
  ```bash
python dev_test_code.py
```

## Data Source

The adverse event data comes from the `pharmaversesdtm` R package, which provides CDISC-compliant clinical trial datasets for educational purposes.

## Question 6: GenAI Clinical Data Assistant

**Location**: `question_6/`

LLM-powered assistant for clinical data queries using LangChain.

## Technologies

**R**: devtools, usethis, roxygen2, testthat, Pharmaverse (admiral, sdtm.oak)  
**Python**: FastAPI, LangChain, Pydantic, OpenAI/Anthropic APIs  
**Standards**: CDISC SDTM, ADaM, ICH guidelines

## Requirements

### R Environment
- R version ≥ 4.0.0
- RStudio (recommended)
- Required packages: devtools, usethis, roxygen2, testthat

### Python Environment
- Python ≥ 3.9
- pip or conda for package management

## Progress

- [x] Repository setup
- [ ] Question 1: Descriptive Statistics Package
- [ ] Question 2: SDTM DS Domain
- [ ] Question 3: ADaM ADSL Dataset
- [ ] Question 4: Adverse Events TLG
- [ ] Question 5: Clinical Data API
- [ ] Question 6: GenAI Assistant

## Licence

MIT

---

*Last updated: [Current Date]*
