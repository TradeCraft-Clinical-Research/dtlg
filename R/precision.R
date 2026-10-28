#' Round half away from zero
#'
#' [round_half_up()] rounds `x` to `digits` decimal places, rounding a value
#' that lies exactly half-way (e.g. `6.25` to one decimal place) **away from
#' zero**, which is how SAS rounds and what most readers of a clinical table
#' expect. Base [round()] (and [sprintf()]) round such ties to the *even*
#' digit instead (`6.25` becomes `6.2`), and values that are ties in decimal
#' but not in binary (e.g. `6.35`, stored as `6.3499999...`) are rounded down.
#'
#' A small tolerance (`1e-9`, or a few machine epsilons for very large values)
#' absorbs binary representation error, so any value that is a tie in decimal
#' is treated as a tie. For percentages of whole counts this is exact for any
#' realistic denominator.
#'
#' @param x A numeric vector. `NA` values are returned as `NA`.
#' @param digits A single non-negative number of decimal places. Defaults to
#'   `0`.
#'
#' @returns A numeric vector of the same length as `x`.
#'
#' @examples
#' round_half_up(c(6.25, 6.35, 0.5, 2.5, -2.5), 1)
#' round_half_up(c(0.5, 1.5, 2.5, -2.5))
#' # Base R rounds ties to even
#' round(c(0.5, 1.5, 2.5, -2.5))
#'
#' @export
#'
round_half_up <- function(x, digits = 0L) {
  stopifnot(
    is.numeric(x),
    is_scalar_number(digits),
    digits >= 0L
  )

  m <- 10 ^ digits
  y <- abs(x) * m
  tol <- pmax(1e-9, 4 * .Machine$double.eps * y)
  res <- sign(x) * floor(y + 0.5 + tol) / m
  # Avoid "-0": a small negative value that rounds to zero must print as zero
  res[!is.na(res) & res == 0] <- 0
  res
}

#' Format numbers with a fixed number of decimals (half away from zero)
#'
#' [format_fixed()] formats `x` as strings with exactly `digits` decimal places
#' after rounding with [round_half_up()], so that, for example, `6.25` becomes
#' `"6.3"` and `5` becomes `"5.0"`.
#'
#' @param x A numeric vector.
#' @param digits A single non-negative number of decimal places. Defaults to
#'   `1`.
#'
#' @returns A character vector; `NA` values give `NA_character_`.
#'
#' @examples
#' format_fixed(c(6.25, 5, 12.345, NA), digits = 1)
#' format_fixed(0.0625 * 100, digits = 1)
#'
#' @export
#'
format_fixed <- function(x, digits = 1L) {
  stopifnot(
    is.numeric(x),
    is_scalar_number(digits),
    digits >= 0L
  )

  out <- sprintf(paste0("%.", as.integer(digits), "f"), round_half_up(x, digits))
  out[is.na(x)] <- NA_character_
  out
}

#' Number of decimal places in the source values
#'
#' [source_decimals()] returns the largest number of decimal places that the
#' non-missing values of `x` actually use, e.g. `c(4.5, 4.25, 7)` has two. It is
#' meant to be computed on the raw analysis values (e.g. `AVAL` of one lab
#' parameter, across all treatment arms and visits) so that summary statistics
#' can be shown with a precision relative to the source data.
#'
#' Numeric data does not keep trailing zeros (`4.50` is stored as `4.5`), so the
#' result is the precision *found in the data* and can understate the precision
#' of the collected values if no value shows a trailing zero. Binary noise (e.g.
#' `0.1 + 0.2`) is ignored. At most `max_dec` decimals are reported, which stops
#' derived values such as a calculated BMI from producing very long numbers.
#'
#' @param x A numeric vector. Non-finite values are ignored.
#' @param max_dec Largest number of decimals to report. Defaults to `4`.
#'
#' @returns A single integer, `0` when there is no finite value.
#'
#' @examples
#' source_decimals(c(4.5, 4.25, 7))
#' source_decimals(c(30, 35, NA))
#' source_decimals(c(0.1 + 0.2, 1))
#'
#' @export
#'
source_decimals <- function(x, max_dec = 4L) {
  stopifnot(is.numeric(x), is_scalar_number(max_dec), max_dec >= 0L)

  x <- abs(x[is.finite(x)])
  if (length(x) == 0L) {
    return(0L)
  }

  for (d in seq.int(0L, as.integer(max_dec))) {
    y <- x * 10 ^ d
    tol <- pmax(1e-9, 4 * .Machine$double.eps * y)
    if (all(abs(y - round(y)) <= tol)) {
      return(d)
    }
  }
  as.integer(max_dec)
}

#' Decimal places of each summary statistic, relative to the source precision
#'
#' Standard convention for continuous data: mean and median one more decimal
#' than the source, standard deviation two more, minimum and maximum the same
#' as the source.
#'
#' @param src_dec Number of decimals of the source values.
#'
#' @returns A named list with `mean`, `sd`, `median` and `min_max`.
#'
#' @noRd
#' @keywords internal
#'
desc_digits <- function(src_dec) {
  stopifnot(is_scalar_number(src_dec), src_dec >= 0L)
  src_dec <- as.integer(src_dec)
  list(
    mean = src_dec + 1L,
    sd = src_dec + 2L,
    median = src_dec + 1L,
    min_max = src_dec
  )
}
