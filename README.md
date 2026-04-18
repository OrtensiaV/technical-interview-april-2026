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

**Location**: `question_3/`

Creation of Analysis Data Model (ADaM) Subject-Level Analysis Dataset (ADSL).

## Question 4: TLG - Adverse Events Reporting

**Location**: `question_4/`

Tables, Listings, and Graphs for adverse events reporting following regulatory standards.

## Question 5: Clinical Data API (FastAPI)

**Location**: `question_5/`

RESTful API for clinical data access and manipulation built with FastAPI.

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

## Author

Ortensia Vito

## Licence

MIT

---

*Last updated: [Current Date]*