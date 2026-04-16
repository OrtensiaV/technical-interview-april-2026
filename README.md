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

**Location**: `question_2/`

Implementation of SDTM Disposition (DS) domain using `sdtm.oak` from Pharmaverse.

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