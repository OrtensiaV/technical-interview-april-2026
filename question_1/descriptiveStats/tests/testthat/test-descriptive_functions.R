# Test calc_mean
test_that("calc_mean works correctly", {
  expect_equal(calc_mean(c(1, 2, 3, 4, 5)), 3)
  expect_equal(calc_mean(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 4.3)
  expect_equal(calc_mean(c(10)), 10)
  expect_warning(calc_mean(c()), "Empty vector")
  expect_warning(calc_mean(c(NA, NA, NA)), "No non-NA values")
  expect_error(calc_mean("text"), "Input must be a numeric vector")
})

# Test calc_median
test_that("calc_median works correctly", {
  expect_equal(calc_median(c(1, 2, 3, 4, 5)), 3)
  expect_equal(calc_median(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 4.5)
  expect_equal(calc_median(c(1, 2, 3, 4)), 2.5)
  expect_equal(calc_median(c(10)), 10)
  expect_warning(calc_median(c()), "Empty vector")
  expect_error(calc_median("text"), "Input must be a numeric vector")
})

# Test calc_mode
test_that("calc_mode works correctly", {
  expect_equal(calc_mode(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 5)
  expect_equal(calc_mode(c(1, 1, 1, 2, 3)), 1)
  expect_warning(calc_mode(c(1, 2, 3, 4, 5)), "No mode exists")
  expect_message(calc_mode(c(1, 1, 2, 2, 3)), "Multiple modes exist")
  expect_warning(calc_mode(c()), "Empty vector")
  expect_error(calc_mode("text"), "Input must be a numeric vector")
})

# Test calc_q1
test_that("calc_q1 works correctly", {
  expect_equal(calc_q1(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 2)
  expect_equal(calc_q1(c(1, 2, 3, 4, 5)), 1.5)
  expect_warning(calc_q1(c()), "Empty vector")
  expect_error(calc_q1("text"), "Input must be a numeric vector")
})

# Test calc_q3
test_that("calc_q3 works correctly", {
  expect_equal(calc_q3(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 5)
  expect_equal(calc_q3(c(1, 2, 3, 4, 5)), 4.5)
  expect_warning(calc_q3(c()), "Empty vector")
  expect_error(calc_q3("text"), "Input must be a numeric vector")
})

# Test calc_iqr
test_that("calc_iqr works correctly", {
  expect_equal(calc_iqr(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 3)
  expect_equal(calc_iqr(c(1, 2, 3, 4, 5)), 3)
  expect_warning(calc_iqr(c()), "Empty vector")
  expect_error(calc_iqr("text"), "Input must be a numeric vector")
})

# Test NA handling across all functions
test_that("NA values are handled correctly", {
  data_with_na <- c(1, 2, NA, 4, 5)

  expect_equal(calc_mean(data_with_na, na.rm = TRUE), 3)
  expect_equal(calc_median(data_with_na, na.rm = TRUE), 3)
  expect_true(is.na(calc_mean(data_with_na, na.rm = FALSE)))
})

# Test NA handling with na.rm parameter
test_that("na.rm parameter works correctly across all functions", {
  data_with_na <- c(1, 2, NA, 4, 5)

  # Test with na.rm = TRUE (should calculate ignoring NAs)
  expect_equal(calc_mean(data_with_na, na.rm = TRUE), 3)
  expect_equal(calc_median(data_with_na, na.rm = TRUE), 3)
  expect_equal(calc_q1(data_with_na, na.rm = TRUE), 1.5)
  expect_equal(calc_q3(data_with_na, na.rm = TRUE), 4.5)
  expect_equal(calc_iqr(data_with_na, na.rm = TRUE), 3)

  # Test with na.rm = FALSE (should return NA)
  expect_true(is.na(calc_mean(data_with_na, na.rm = FALSE)))
  expect_true(is.na(calc_median(data_with_na, na.rm = FALSE)))
  expect_true(is.na(calc_q1(data_with_na, na.rm = FALSE)))
  expect_true(is.na(calc_q3(data_with_na, na.rm = FALSE)))
  expect_true(is.na(calc_iqr(data_with_na, na.rm = FALSE)))

  # Mode requires special handling due to frequency counting
  # With NA removed, mode should work
  data_mode_na <- c(1, 2, 2, NA, 3)
  expect_equal(calc_mode(data_mode_na, na.rm = TRUE), 2)
  expect_true(is.na(calc_mode(data_mode_na, na.rm = FALSE)))
})

# Test edge case: all NA values
test_that("functions handle all-NA vectors correctly", {
  all_na <- c(NA_real_, NA_real_, NA_real_)

  expect_warning(calc_mean(all_na, na.rm = TRUE), "No non-NA values")
  expect_warning(calc_median(all_na, na.rm = TRUE), "No non-NA values")
  expect_warning(calc_mode(all_na, na.rm = TRUE), "No non-NA values")
  expect_warning(calc_q1(all_na, na.rm = TRUE), "No non-NA values")
  expect_warning(calc_q3(all_na, na.rm = TRUE), "No non-NA values")

  expect_true(is.na(calc_mean(all_na, na.rm = FALSE)))
  expect_true(is.na(calc_median(all_na, na.rm = FALSE)))
})

# Test edge case: single NA value
test_that("functions handle single NA value correctly", {
  single_na <- c(NA_real_)

  expect_warning(calc_mean(single_na, na.rm = TRUE), "No non-NA values")
  expect_true(is.na(calc_mean(single_na, na.rm = FALSE)))
  expect_true(is.na(calc_median(single_na, na.rm = FALSE)))
})

# Test mixed data with multiple NAs
test_that("functions handle multiple NAs correctly", {
  multi_na <- c(1, NA, 3, NA, 5, NA, 7)

  expect_equal(calc_mean(multi_na, na.rm = TRUE), 4)
  expect_equal(calc_median(multi_na, na.rm = TRUE), 4)
  expect_true(is.na(calc_mean(multi_na, na.rm = FALSE)))
  expect_true(is.na(calc_median(multi_na, na.rm = FALSE)))
})
