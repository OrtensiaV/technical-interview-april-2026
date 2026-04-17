# descriptiveStats

An R package for calculating descriptive statistics with robust error handling and edge case management.

## Overview

`descriptiveStats` provides six core functions for calculating common descriptive statistics:

- **Central Tendency**: mean, median, mode
- **Dispersion**: first quartile (Q1), third quartile (Q3), interquartile range (IQR)

All functions include proper handling of missing values, empty vectors, and edge cases.

## Installation

Install directly from the package directory:

```r
devtools::install("question_1/descriptiveStats")
library(descriptiveStats)
```

## Functions

### Central Tendency

- `calc_mean(x, na.rm = TRUE)` - Arithmetic mean
- `calc_median(x, na.rm = TRUE)` - Median value
- `calc_mode(x, na.rm = TRUE)` - Most frequent value

### Dispersion

- `calc_q1(x, na.rm = TRUE)` - First quartile using hinges method
- `calc_q3(x, na.rm = TRUE)` - Third quartile using hinges method
- `calc_iqr(x, na.rm = TRUE)` - Interquartile range (Q3 - Q1)

## Usage Examples

```r
library(descriptiveStats)

# Example data
data <- c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)

# Calculate statistics
calc_mean(data)    # 4.3
calc_median(data)  # 4.5
calc_mode(data)    # 5
calc_q1(data)      # 2
calc_q3(data)      # 5
calc_iqr(data)     # 3

# Handle missing values
data_with_na <- c(1, 2, NA, 4, 5)
calc_mean(data_with_na, na.rm = TRUE)   # 3
calc_median(data_with_na, na.rm = FALSE) # NA
```

## Methodology

### Quartile Calculation

This package uses the **hinges method** (Tukey's method) for calculating quartiles:

1. The dataset is sorted in ascending order
2. The data is split into lower and upper halves based on the median
3. Q1 is the median of the lower half
4. Q3 is the median of the upper half

This approach is commonly used in exploratory data analysis and produces intuitive results for box plots.

## Features

### Robust Error Handling

- Clear error messages for invalid inputs
- Graceful handling of empty vectors
- Proper NA value management
- Type coercion for logical NA vectors

### Edge Cases

The package handles various edge cases:

```r
# Empty vectors
calc_mean(c())  # Warning: "Empty vector provided"

# Vectors with only NAs
calc_mean(c(NA, NA, NA))  # Warning: "No non-NA values"

# No mode (all values equally frequent)
calc_mode(c(1, 2, 3, 4, 5))  # Warning: "No mode exists"

# Multiple modes
calc_mode(c(1, 1, 2, 2, 3))  # Returns smallest mode with message

# Single value
calc_median(c(5))  # Returns 5
```

## Documentation

Access function documentation:

```r
?calc_mean
?calc_median
?calc_mode
?calc_q1
?calc_q3
?calc_iqr
```

## Testing

The package includes comprehensive unit tests covering:

- Standard calculations
- Edge cases (empty vectors, single values)
- NA handling with `na.rm = TRUE` and `na.rm = FALSE`
- Input validation
- Error and warning messages
- Mode calculation with ties and no mode scenarios

Run tests:

```r
devtools::test()
```

## Package Structure

```
descriptiveStats/
├── DESCRIPTION          # Package metadata
├── NAMESPACE            # Exported functions
├── LICENCE              # MIT licence
├── README.md            # This file
├── R/
│   └── descriptive_functions.R  # All six functions
├── man/                 # Auto-generated documentation
│   ├── calc_mean.Rd
│   ├── calc_median.Rd
│   ├── calc_mode.Rd
│   ├── calc_q1.Rd
│   ├── calc_q3.Rd
│   └── calc_iqr.Rd
└── tests/
    └── testthat/
        └── test-descriptive_functions.R  # Unit tests
```

## Requirements

- R ≥ 4.0.0
- No external dependencies (base R only)

## Development

Built using:

- `devtools` for package development workflow
- `usethis` for package setup and configuration
- `roxygen2` for documentation generation
- `testthat` for unit testing

## Licence

MIT

## Author

Ortensia Vito

## Version History

**0.1.0** (Initial Release)
- Six core descriptive statistics functions
- Comprehensive error handling
- Full test coverage
- Complete documentation
```
