test_that("round_half_up rounds ties away from zero, like SAS", {
  expect_equal(round_half_up(c(6.25, 6.35, 0.5, 1.5, 2.5), 1), c(6.3, 6.4, 0.5, 1.5, 2.5))
  expect_equal(round_half_up(c(0.5, 1.5, 2.5, -0.5, -2.5)), c(1, 2, 3, -1, -3))
  expect_equal(round_half_up(0.0625 * 100, 1), 6.3)
  expect_equal(round_half_up(12.5, 0), 13)
  expect_equal(round_half_up(1.005, 2), 1.01) # binary 1.00499999...
  expect_equal(round_half_up(2.675, 2), 2.68)
  expect_equal(round_half_up(c(1.24, 1.26), 1), c(1.2, 1.3))
})

test_that("round_half_up handles NA, empty, negative zero and large values", {
  expect_equal(round_half_up(c(NA, 2.25), 1), c(NA, 2.3))
  expect_equal(round_half_up(numeric(0), 1), numeric(0))
  expect_identical(sprintf("%.1f", round_half_up(-0.04, 1)), "0.0")
  expect_equal(round_half_up(123456789.5, 0), 123456790)
  expect_error(round_half_up("a"))
  expect_error(round_half_up(1, -1))
})

test_that("round_half_up agrees with exact tie rounding for every percentage of realistic counts", {
  for (den in c(8, 16, 32, 40, 48, 64, 80, 160, 200, 320)) {
    n <- 0:den
    pct <- 100 * n / den
    exact <- floor(pct * 10 + 0.5 + 1e-7) / 10 # reference with a wide tolerance
    expect_equal(round_half_up(pct, 1), exact, info = den)
  }
})

test_that("format_fixed keeps trailing zeros and gives NA_character_", {
  expect_identical(format_fixed(c(5, 6.25, NA, 12.345), 1), c("5.0", "6.3", NA, "12.3"))
  expect_identical(format_fixed(5, 0), "5")
  expect_identical(format_fixed(0.0625 * 100, 1), "6.3")
  expect_identical(format_fixed(-0.04, 1), "0.0")
})

test_that("source_decimals finds the largest precision in the data", {
  expect_identical(source_decimals(c(4.5, 4.25, 7)), 2L)
  expect_identical(source_decimals(c(30, 35, NA)), 0L)
  expect_identical(source_decimals(c(0.1 + 0.2, 1)), 1L)
  expect_identical(source_decimals(c(NA_real_, Inf)), 0L)
  expect_identical(source_decimals(numeric(0)), 0L)
  expect_identical(source_decimals(c(1 / 3, 1)), 4L) # capped
  expect_identical(source_decimals(c(1 / 3, 1), max_dec = 2L), 2L)
  expect_identical(source_decimals(c(-1.25, 3)), 2L)
  expect_identical(source_decimals(c(0.001, 12.5)), 3L)
})

test_that("desc_digits: mean/median +1, sd +2, min/max same as source", {
  expect_equal(desc_digits(0L), list(mean = 1L, sd = 2L, median = 1L, min_max = 0L))
  expect_equal(desc_digits(2L), list(mean = 3L, sd = 4L, median = 3L, min_max = 2L))
})

test_that("calc_desc derives decimals from the source precision by default", {
  dt <- data.frame(
    ARM = rep(c("A", "B"), each = 3),
    VAL = c(4.5, 4.25, 7, 5, 6.5, 8)
  )
  res <- calc_desc(dt, "VAL", treat = "ARM", indent = "")[[1]]
  # source has 2 decimals -> mean/median 3, SD 4, min/max 2
  expect_identical(res$A[3], "5.250 (1.5207)")
  expect_identical(res$B[3], "6.500 (1.5000)")
  expect_identical(res$A[4], "4.500")
  expect_identical(res$A[5], "4.25, 7.00")
  expect_identical(res$B[5], "5.00, 8.00")

  # integer source: mean/median 1, SD 2, min/max 0
  a <- data.frame(ARM = c("A", "A", "B", "B"), AGE = c(30L, 35L, 41L, 50L))
  res <- calc_desc(a, "AGE", treat = "ARM", indent = "")[[1]]
  expect_identical(res$A[3], "32.5 (3.54)")
  expect_identical(res$B[4], "45.5")
  expect_identical(res$A[5], "30, 35")
})

test_that("calc_desc: explicit pct_dec keeps the legacy single-precision behaviour, src_dec overrides", {
  dt <- data.frame(ARM = rep(c("A", "B"), each = 3), VAL = c(4.5, 4.25, 7, 5, 6.5, 8))
  res <- calc_desc(dt, "VAL", treat = "ARM", indent = "", pct_dec = 1)[[1]]
  expect_identical(res$A[3], "5.3 (1.5)")
  expect_identical(res$A[4], "4.5")
  expect_identical(res$A[5], "4.3, 7.0")
  res <- calc_desc(dt, "VAL", treat = "ARM", indent = "", src_dec = 0L)[[1]]
  expect_identical(res$A[3], "5.3 (1.52)")
  expect_identical(res$A[5], "4, 7")
})

test_that("summary_table_by uses one precision per first grouping value across visits", {
  dt <- data.frame(
    PARAM = rep(c("ALT", "pH"), each = 8),
    AVISIT = rep(rep(c("V1", "V2"), each = 4), times = 2),
    ARM = rep(c("A", "A", "B", "B"), 4),
    AVAL = c(10, 12, 11, 13, 14, 16, 15, 17,
             7.25, 7.5, 7, 7.4, 7, 7.5, 7.5, 7.5)
  )
  res <- summary_table_by(dt, target = "AVAL", treat = "ARM", rows_by = c("PARAM", "AVISIT"), indent = "")[[1]]
  ms <- res[stats %in% "Mean (SD)"]
  # ALT: whole numbers -> mean 1 decimal, SD 2
  expect_identical(ms$A[1], "11.0 (1.41)")
  expect_identical(ms$A[2], "15.0 (1.41)")
  # pH: 2 decimals found in V1 -> V2 (which only shows 1 decimal) also gets 3 / 4
  expect_identical(ms$A[3], "7.375 (0.1768)")
  expect_identical(ms$A[4], "7.250 (0.3536)")
})
