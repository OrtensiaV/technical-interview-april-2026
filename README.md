# Clinical Programming Assessment Portfolio

Comprehensive solutions demonstrating clinical data programming expertise across R and Python, covering regulatory standards, data engineering, and modern AI applications.

## Overview

This repository contains solutions to six technical exercises spanning:
  
- **R Package Development**: Custom statistical functions with full documentation
- **CDISC Standards**: SDTM and ADaM dataset creation using Pharmaverse
- **Regulatory Reporting**: Tables, Listings, and Graphs (TLGs) for clinical trials
- **API Development**: RESTful clinical data services with FastAPI
- **GenAI Applications**: LLM-powered clinical data assistant

## Repository Structure

```
├── question_1/             # Descriptive Statistics R Package
  ├── question_2_sdtm/        # SDTM DS Domain Creation
  ├── question_3_adam/        # ADaM ADSL Dataset Creation
  ├── question_4_tlg/         # Adverse Events TLG Reporting
  ├── question_5/             # Clinical Data API (FastAPI)
  ├── question_6/             # GenAI Clinical Data Assistant
  └── README.md
```

## Author

Ortensia Vito

---
  
## Question 1: Descriptive Statistics R Package
  
**Location**: `question_1/descriptive_stats/`

### Overview

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

### Documentation

See `question_1/descriptive_stats/README.md` for detailed documentation.

---
  
## Question 2: SDTM DS Domain Creation
  
**Location**: `question_2_sdtm/02_create_ds_domain.R`

### Overview

Creation of an SDTM Disposition (DS) domain dataset from raw clinical trial data using the `{sdtm.oak}` package. The DS domain captures subject disposition events throughout the clinical trial, including protocol milestones and disposition events.

### Key Features

- **Conditional Mapping Logic**: Implements business rules for DSTERM, DSDECOD, and DSCAT based on aCRF specifications
- **Controlled Terminology**: Applies CT mappings for visit variables using study CT specifications
- **Date Handling**: Converts raw dates and times to ISO8601 format
- **Study Day Derivation**: Calculates DSSTDY relative to reference start date from DM domain
- **Sequence Generation**: Derives DSSEQ per subject based on USUBJID and DSTERM

### Implementation

The script utilises `{sdtm.oak}` functions including:
  
- `assign_no_ct()`: Direct variable assignments without controlled terminology
- `assign_ct()`: Variable assignments with controlled terminology mappings
- `hardcode_no_ct()`: Hardcoded value assignments for categorical variables
- `condition_add()`: Conditional filtering based on business rules
- `derive_seq()`: Sequence number derivation
- `derive_study_day()`: Study day calculation relative to reference dates

### Business Rules

1. When OTHERSP is null, map IT.DSTERM to DSTERM and IT.DSDECOD to DSDECOD
2. When OTHERSP is not null, map OTHERSP to both DSTERM and DSDECOD
3. When IT.DSDECOD equals "Randomized", assign DSCAT as "PROTOCOL MILESTONE"
4. When IT.DSDECOD does not equal "Randomized" and OTHERSP is null, assign DSCAT as "DISPOSITION EVENT"
5. When OTHERSP is not null, assign DSCAT as "OTHER EVENT"

### Output Variables

STUDYID, DOMAIN, USUBJID, DSSEQ, DSTERM, DSDECOD, DSCAT, VISITNUM, VISIT, DSDTC, DSSTDTC, DSSTDY

### Data Sources

- **Raw Data**: `pharmaverseraw::ds_raw`
- **Reference Domain**: `pharmaversesdtm::dm`
- **Controlled Terminology**: `"raw_data/sdtm_ct.csv"` from `{sdtm.oak}` package

---
  
## Question 3: ADaM ADSL Dataset Creation
  
**Location**: `question_3_adam/create_adsl.R`

### Overview

Creation of Analysis Data Model (ADaM) Subject-Level Analysis Dataset (ADSL) from SDTM source data using the {admiral} family of packages and tidyverse tools, following Pharmaverse standards and CDISC ADaM guidelines. The ADSL dataset contains one record per subject with key demographic, treatment, and derived variables.

### Data Sources

The programme uses the following SDTM domains from the `pharmaversesdtm` package:
  
- **DM** (Demographics): Base dataset for subject-level information
- **EX** (Exposure): Treatment administration records
- **VS** (Vital Signs): Blood pressure measurements
- **AE** (Adverse Events): Adverse event records
- **DS** (Disposition): Study disposition events

### Key Derived Variables

**AGEGR9 & AGEGR9N**: Age grouping variables categorising subjects into `"<18"`, `"18-50"`, `">50"` with numeric equivalents (1, 2, 3)

**TRTSDTM & TRTSTMF**: Treatment start date-time derived from first valid exposure record. Missing time components imputed to 00:00:00. Valid dose criteria: EXDOSE > 0 OR (EXDOSE = 0 AND EXTRT contains "PLACEBO")

**TRTEDTM & TRTETMF**: Treatment end date-time derived from last valid exposure record with similar imputation logic

**ITTFL**: Intent-to-Treat Flag indicating whether subject was randomised (`"Y"` if ARM populated, `"N"` otherwise)

**ABNSBPFL**: Abnormal Systolic Blood Pressure Flag identifying subjects with any systolic BP <100 or ≥140 mmHg

**LSTALVDT**: Last Known Alive Date representing maximum date across vital signs, adverse events, disposition events, and treatment administration (complete dates only)

**CARPOPFL**: Cardiac Population Flag identifying subjects with cardiac adverse events (`"Y"` if at least one AE in "CARDIAC DISORDERS" system organ class)

### Usage

```r
source("question_3_adam/create_adsl.R")
```

The script will load SDTM source datasets, derive all required variables, and output the final ADSL dataset.

---
  
## Question 4: TLG - Adverse Events Reporting
  
**Location**: `question_4_tlg/`

### Overview

Creation of Tables, Listings, and Graphs (TLGs) for adverse events summary using the `pharmaverseadam::adae` and `pharmaverseadam::adsl` datasets.

### Objectives

- Generate summary table of treatment-emergent adverse events by system organ class
- Visualise adverse event severity distribution across treatment arms
- Identify and display top 10 most frequent adverse events with confidence intervals
- Produce detailed listing of all treatment-emergent adverse events

### Scripts

**01_create_ae_summary_table.R**: Creates hierarchical summary table of TEAEs organised by SOC and AEDECOD. Filters for treatment-emergent events, displays counts and percentages by treatment arm, includes overall summary for serious adverse events.

**02_create_visualizations.R**: Generates two visualisations - stacked bar chart of AE severity distribution by treatment arm, and forest plot of top 10 most frequent AEs with 95% confidence intervals.

**03_create_listings.R**: Produces detailed patient-level listing of all TEAEs including subject ID, treatment arm, event term, severity, relationship to study drug, and dates.

### Usage

Execute scripts in numerical order:
  
```r
source("question_4_tlg/01_create_ae_summary_table.R")
source("question_4_tlg/02_create_visualizations.R")
source("question_4_tlg/03_create_listings.R")
```

### Outputs

- `ae_summary_table.html` - Hierarchical summary table
- `ae_severity_distribution_by_treatment.png` - Severity distribution visualisation
- `top_10_aes.png` - Top 10 AEs with confidence intervals
- `ae_listings.html` - Detailed patient-level listing

---
  
## Question 5: Clinical Data API (FastAPI)
  
**Location**: `question_5/`

### Overview

A RESTful API built with FastAPI for querying and analysing clinical trial adverse event data. The API provides three endpoints for dynamic filtering, risk score calculation, and data access.

### Features

- Dynamic filtering of adverse events by severity and treatment arm
- Patient risk score calculation based on adverse event severity
- RESTful API design with comprehensive error handling

### Endpoints

**GET `/`**: Returns welcome message confirming API status

**POST `/ae-query`**: Filters adverse events based on optional severity list and treatment arm. Returns count of matching records and list of unique subject IDs.

**GET `/subject-risk/{subject_id}`**: Calculates safety risk score for specific patient. Scoring: MILD (1 point), MODERATE (3 points), SEVERE (5 points). Risk categories: Low (<5), Medium (5-14), High (≥15).

### Installation

```bash
git clone https://github.com/OrtensiaV/technical-interview-april-2026
cd technical-interview-april-2026/question_5
pip install fastapi uvicorn pandas pydantic
```

### Usage

Start the server:
  
  ```bash
uvicorn main:app --reload
```

Access the API:
  
- Interactive documentation: `http://localhost:8000/docs`
- Alternative documentation: `http://localhost:8000/redoc`
- Welcome endpoint: `http://localhost:8000/`

### Testing

```bash
python dev_test_code.py
```

### Data Source

Adverse event data from `pharmaversesdtm` R package.

---
  
 ## Question 6: GenAI Clinical Data Assistant
  
**Location**: `question_6/`

### Overview

An AI-powered assistant that translates natural language questions into structured Pandas queries on clinical trial adverse event data. The assistant enables users to query the dataset using plain English without requiring knowledge of specific column names.

### Features

- Natural language query parsing using GPT-3.5-turbo or rule-based fallback
- Automatic mapping of user intent to appropriate dataset columns
- Structured JSON output with target column and filter value
- Support for severity, condition, body system, and treatment arm queries

### Column Mapping

- Questions about "severity" or "intensity" → AESEV column
- Questions about specific conditions (e.g., "headache") → AETERM column
- Questions about body systems (e.g., "cardiac disorders") → AESOC column
- Questions about treatment groups → ACTARM column

### Implementation

The solution consists of a `ClinicalTrialDataAgent` class with two operational modes:
  
**OpenAI Mode**: Uses GPT-3.5-turbo to parse natural language queries.

**Mock Mode**: Rule-based parser using keyword matching for environments without API access.

### Workflow

1. User submits natural language question
2. Agent parses question into structured parameters (target column and filter value)
3. Query executes on dataframe using Pandas operations
4. Results return count of matching subjects and their IDs

### Usage

```python
# Create agent with OpenAI
agent = ClinicalTrialDataAgent(df, use_openai=True, api_key="your-key")

# Or use mock parser
agent = ClinicalTrialDataAgent(df, use_openai=False)

# Ask questions
result = agent.ask("Give me subjects with moderate severity adverse events")
```

### Testing

Three test queries demonstrate system functionality:
  
- Severity-based filtering
- Specific adverse event term queries
- System organ class filtering

---
  
## Requirements
  
### R Environment
  
- R version ≥ 4.0.0
- RStudio (recommended)
- Required packages: devtools, usethis, roxygen2, testthat, sdtm.oak, pharmaverseraw, pharmaversesdtm, dplyr, lubridate, admiral, stringr, pharmaverseadam, gtsummary, ggplot2, gtreg

### Python Environment

- Python ≥ 3.9
- pip or conda for package management
- Required packages: pandas, fastapi, uvicorn, pydantic, openai

## Licence

MIT

---
  
  *Last updated: 25 April 2026*
