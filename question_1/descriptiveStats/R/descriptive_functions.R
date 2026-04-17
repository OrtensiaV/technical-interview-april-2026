#' Calculate Arithmetic Mean
#'
#' Computes the arithmetic mean of a numeric vector.
#'
#' @param x A numeric vector
#' @param na.rm Logical. Should missing values be removed? Default is TRUE.
#'
#' @return The arithmetic mean as a numeric value, or NA if the vector is empty
#'   or contains only NA values.
#'
#' @examples
#' calc_mean(c(1, 2, 3, 4, 5))
#' calc_mean(c(1, 2, NA, 4, 5), na.rm = TRUE)
#' calc_mean(c(10, 20, 30))
#'
#' @export
calc_mean <- function(x, na.rm = TRUE) {
  if (length(x) == 0) {
    warning("Empty vector provided")
    return(NA_real_)
  }

  if (!is.numeric(x)) {
    if (is.logical(x) && all(is.na(x))){
      x <- as.numeric(x)
    } else if (!is.numeric(x)) {
      stop("Input must be a numeric vector")
    }
  }

  if (!na.rm && any(is.na(x))){
    return(NA_real_)
  }

  if (na.rm) {
    x <- x[!is.na(x)]
  }

  if (length(x) == 0) {
    warning("No non-NA values to calculate mean")
    return(NA_real_)
  }

  return(sum(x) / length(x))
}


#' Calculate Median
#'
#' Computes the median (middle value) of a numeric vector.
#'
#' @param x A numeric vector
#' @param na.rm Logical. Should missing values be removed? Default is TRUE.
#'
#' @return The median as a numeric value, or NA if the vector is empty
#'   or contains only NA values.
#'
#' @examples
#' calc_median(c(1, 2, 3, 4, 5))
#' calc_median(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10))
#' calc_median(c(10, 20, 30, 40))
#'
#' @export
calc_median <- function(x, na.rm = TRUE) {
  if (length(x) == 0) {
    warning("Empty vector provided")
    return(NA_real_)
  }

  if (!is.numeric(x)) {
    stop("Input must be a numeric vector")
  }

  if (!na.rm && any(is.na(x))){
    return(NA_real_)
  }

  if (na.rm) {
    x <- x[!is.na(x)]
  }

  if (length(x) == 0) {
    warning("No non-NA values to calculate median")
    return(NA_real_)
  }

  x_sorted <- sort(x)
  n <- length(x_sorted)

  if (n %% 2 == 1) {
    return(x_sorted[(n + 1) / 2])
  } else {
    return((x_sorted[n / 2] + x_sorted[n / 2 + 1]) / 2)
  }
}


#' Calculate Mode
#'
#' Computes the mode (most frequent value) of a numeric vector. Handles cases
#' with multiple modes or no mode.
#'
#' @param x A numeric vector
#' @param na.rm Logical. Should missing values be removed? Default is TRUE.
#'
#' @return The mode as a numeric value. If multiple modes exist, returns the
#'   smallest value. Returns NA if no mode exists (all values equally frequent)
#'   or if the vector is empty.
#'
#' @examples
#' calc_mode(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10))
#' calc_mode(c(1, 1, 2, 2, 3, 3))  # Multiple modes, returns smallest
#' calc_mode(c(1, 2, 3, 4, 5))     # No mode, returns NA
#'
#' @export
calc_mode <- function(x, na.rm = TRUE) {
  if (length(x) == 0) {
    warning("Empty vector provided")
    return(NA_real_)
  }

  if (!is.numeric(x)) {
    stop("Input must be a numeric vector")
  }

  if (!na.rm && any(is.na(x))){
    return(NA_real_)
  }

  if (na.rm) {
    x <- x[!is.na(x)]
  }

  if (length(x) == 0) {
    warning("No non-NA values to calculate mode")
    return(NA_real_)
  }

  freq_table <- table(x)
  max_freq <- max(freq_table)

  if (max_freq == 1) {
    warning("No mode exists (all values equally frequent)")
    return(NA_real_)
  }

  modes <- as.numeric(names(freq_table[freq_table == max_freq]))

  if (length(modes) > 1) {
    message("Multiple modes exist, returning smallest value")
  }

  return(min(modes))
}

#' Calculate First Quartile (Q1)
#'
#' Computes the first quartile using the hinges method (median of lower half).
#'
#' @param x A numeric vector
#' @param na.rm Logical. Should missing values be removed? Default is TRUE.
#'
#' @return The first quartile as a numeric value, or NA if the vector is empty
#'   or contains only NA values.
#'
#' @examples
#' calc_q1(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10))
#' calc_q1(c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10))
#'
#' @export
calc_q1 <- function(x, na.rm = TRUE) {
  if (length(x) == 0) {
    warning("Empty vector provided")
    return(NA_real_)
  }

  if (is.logical(x) && all(is.na(x))) {
    x <- as.numeric(x)
  } else if (!is.numeric(x)) {
    stop("Input must be a numeric vector")
  }

  if (!na.rm && any(is.na(x))){
    return(NA_real_)
  }

  if (na.rm) {
    x <- x[!is.na(x)]
  }

  if (length(x) == 0) {
    warning("No non-NA values to calculate Q1")
    return(NA_real_)
  }

  # Sort the data
  x_sorted <- sort(x)
  n <- length(x_sorted)

  # Find median position
  m <- (n + 1) / 2
  lower_half_index <- floor(m)

  # Extract lower half
  if (n %% 2 != 0) {
    # Odd: exclude median
    lower_half <- x_sorted[1:(lower_half_index - 1)]
  } else {
    # Even: include up to middle
    lower_half <- x_sorted[1:lower_half_index]
  }

  # Q1 is median of lower half
  return(calc_median(lower_half))
}

#' Calculate Third Quartile (Q3)
#'
#' Computes the third quartile using the hinges method (median of upper half).
#'
#' @param x A numeric vector
#' @param na.rm Logical. Should missing values be removed? Default is TRUE.
#'
#' @return The third quartile as a numeric value, or NA if the vector is empty
#'   or contains only NA values.
#'
#' @examples
#' calc_q3(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10))
#' calc_q3(c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10))
#'
#' @export
calc_q3 <- function(x, na.rm = TRUE) {
  if (length(x) == 0) {
    warning("Empty vector provided")
    return(NA_real_)
  }

  if (is.logical(x) && all(is.na(x))) {
    x <- as.numeric(x)
  } else if (!is.numeric(x)) {
    stop("Input must be a numeric vector")
  }

  if (!na.rm && any(is.na(x))){
    return(NA_real_)
  }

  if (na.rm) {
    x <- x[!is.na(x)]
  }

  if (length(x) == 0) {
    warning("No non-NA values to calculate Q3")
    return(NA_real_)
  }

  # Sort the data
  x_sorted <- sort(x)
  n <- length(x_sorted)

  # Find median position
  m <- (n + 1) / 2
  lower_half_index <- floor(m)

  # Extract upper half
  if (n %% 2 != 0) {
    # Odd: exclude median, start after it
    upper_half <- x_sorted[(lower_half_index + 1):n]
  } else {
    # Even: start from second half
    upper_half <- x_sorted[(lower_half_index + 1):n]
  }

  # Q3 is median of upper half
  return(calc_median(upper_half))
}

#' Calculate Interquartile Range (IQR)
#'
#' Computes the interquartile range (Q3 - Q1) of a numeric vector.
#'
#' @param x A numeric vector
#' @param na.rm Logical. Should missing values be removed? Default is TRUE.
#'
#' @return The IQR as a numeric value, or NA if the vector is empty
#'   or contains only NA values.
#'
#' @examples
#' calc_iqr(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10))
#' calc_iqr(c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10))
#'
#' @export
calc_iqr <- function(x, na.rm = TRUE) {
  if (length(x) == 0) {
    warning("Empty vector provided")
    return(NA_real_)
  }

  if (!is.numeric(x)) {
    stop("Input must be a numeric vector")
  }

  q1 <- calc_q1(x, na.rm = na.rm)
  q3 <- calc_q3(x, na.rm = na.rm)

  if (is.na(q1) || is.na(q3)) {
    return(NA_real_)
  }

  return(q3 - q1)
}
