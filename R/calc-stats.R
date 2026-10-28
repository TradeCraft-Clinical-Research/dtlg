#' Calculate descriptive summary statistics for a numeric variable
#'
#' @description
#'
#' [calc_desc()] summarises a numeric variable (`target`) by another (`treat`) and
#' reports summary statistics in clinical trial reporting format. The following
#' statistics are calculated for `target`, per group, i.e. by variable `treat`
#' levels:
#'
#' - `n`: number of observations
#' - `Mean (SD)`: mean and standard deviation of `target`
#' - `Median`: median of `target`
#' - `Min, Max`: minimum and maximum of `target`
#' - `Missing`: number of missing `target` values
#'
#' @param dt A `data.frame` containing, at least, the variables indicated in
#' `target` and `treat`.
#' @param target Target variable passed as a string for which summary
#'   statistics are to be calculated.
#' @param target_name Heading for the target variable as a string. Defaults to
#' `target`.
#' @param treat A string indicating the grouping variable, e.g. the variable
#' specifying the treatment population.
#' @param indent A string to be used as indentation of summary statistics
#' labels. Defaults to four HTML non-breaking spaces (`&nbsp;`).
#' @param pct_dec Decimal places for reported figures. The default, `NULL`,
#' derives the decimals of each statistic from the precision of the source
#' values (see `src_dec`): mean and median one more decimal than the source,
#' standard deviation two more, minimum and maximum the same as the source. A
#' number overrides this and is used for every statistic (the previous
#' behaviour).
#' @param src_dec Number of decimals of the source values, used when `pct_dec`
#' is `NULL`. Defaults to the largest number of decimals found in `target`
#' (see [source_decimals()]). Pass it explicitly when the precision should be
#' taken from a wider set of data than `dt`, e.g. all visits of a lab parameter.
#' @param max_dec Cap on the decimals found in `target` when `src_dec` is not
#' given. Defaults to `4`.
#' @param inc_missing Toggle for including the "Missing" row:
#' \describe{
#' \item{`TRUE`}{(default) The Missing row is always displayed}
#' \item{`NA`}{The Missing row is only displayed if any missing values are present}
#' \item{`FALSE`}{The Missing row is never included in the table}
#' }
#'
#' @returns A list containing a `data.table` formatted as follows:
#'
#' - First column is named `stats` and contains the target variable name
#' indicated in `target` in the first row. Subsequent rows contain the
#' summarised statistics labels.
#'
#' - Other columns are for the levels of the grouping variable (`treat`).
#'
#' - All columns are of character type.
#'
#' This table is structured for easy integration with Shiny output widgets.
#'
#' @examples
#' # Calculate summary statistics for the age of the subjects in each region.
#' calc_desc(dt = adsl, "AGE", treat = "REGION1")[[1]]
#'
#' # Calculate summary statistics for biomarker 1 in each of the three arms
#' # (`ARM`).
#' calc_desc(dt = adsl, "BMRKR1", treat = "ARM")[[1]]
#'
#' @export
#'
calc_desc <- function(dt,
                      target,
                      target_name = target,
                      treat,
                      indent = nbsp(n = 4L),
                      pct_dec = NULL,
                      inc_missing = TRUE,
                      src_dec = NULL,
                      max_dec = 4L) {

  stopifnot(
    is.data.frame(dt),
    is_string(target),
    is_string(target_name),
    is_string(treat),
    is_string(indent),
    is.null(pct_dec) || is.numeric(pct_dec),
    is.null(src_dec) || is_scalar_number(src_dec)
  )

  dt <- maybe_copy_dt(x = dt)

  if (is.null(pct_dec)) {
    if (is.null(src_dec)) {
      src_dec <- source_decimals(dt[[target]], max_dec = max_dec)
    }
    digits <- desc_digits(src_dec)
  } else {
    digits <- list(mean = pct_dec, sd = pct_dec, median = pct_dec, min_max = pct_dec)
  }
  # Bound locally so they are visible to dt_summarise() through `.env`
  d_mean <- digits$mean
  d_sd <- digits$sd
  d_med <- digits$median
  d_mm <- digits$min_max

  dt_stats <- dt_summarise(
    dt,
    .by = treat,
    n = as.character(sum(!is.na(target))),
    `Mean (SD)` = format_mean_sd(
      mean = mean(target, na.rm = TRUE),
      sd = stats::sd(target, na.rm = TRUE),
      .digits = d_mean,
      .sd_digits = d_sd
    ),
    Median = format_fixed(
      stats::median(target, na.rm = TRUE),
      digits = d_med
    ),
    `Min, Max` = format_min_max(
      min = min(target, na.rm = TRUE),
      max = max(target, na.rm = TRUE),
      .digits = d_mm
    ),
    .env = list(
      target = as.name(target),
      d_mean = d_mean,
      d_sd = d_sd,
      d_med = d_med,
      d_mm = d_mm
    )
  )

  if (isTRUE(inc_missing) || (is.na(inc_missing) && anyNA(dt[[target]]))) {
    dt_missing <- dt_summarise(
      dt,
      .by = treat,
      Missing = as.character(sum(is.na(target))),
      .env = list(target = as.name(target))
    )

    dt_stats <- dt_stats[dt_missing, on = treat]
  }

  dt_stats <- data.table::transpose(dt_stats, keep.names = "stats", make.names = treat)
  header <- c(target_name, rep(list(""), times = ncol(dt_stats) - 1L))
  dt_stats[, `:=`(stats = indent(dt_stats$stats, indentation = indent))]
  dt_stats <- rbind(header, dt_stats)

  list(dt_stats)
}


#' Calculate counts of a categorical variable
#'
#' [calc_counts()] counts observations of a categorical variable (`target`) by
#' another (`treat`) and reports summary statistics in clinical trial reporting
#' format.
#'
#' @param dt A `data.frame` containing, at least, the variables indicated in
#' `target` and `treat`.
#' @param target Target variable passed as a string for which summary
#'   statistics are to be calculated.
#' @param target_name Heading for the target variable as a string. Defaults to
#' `target`.
#' @param treat A string indicating the grouping variable, e.g. the variable
#' specifying the treatment population.
#' @param indent A string to be used as indentation of summary statistics
#' labels. Defaults to four HTML non-breaking spaces (`&nbsp;`).
#' @param .total_dt Separate table from `dt` from which to derive total counts
#' per group.
#' @param pct_dec Decimal places for percentages. `NULL` is treated as `1`.
#' Percentages are rounded half away from zero (see [round_half_up()]).
#'
#' @returns A list containing a `data.table` formatted as follows:
#'
#' - First column is named `stats` and contains the target variable name
#' indicated in `target` in the first row. Subsequent rows contain the
#' levels of `target`.
#'
#' - Other columns are for the levels of the grouping variable (`treat`).
#'
#' - All columns are of character type.
#'
#' This table is structured for easy integration with Shiny output widgets.
#'
#' @examples
#' calc_counts(dt = adsl, "RACE", treat = "ARM", indent = "  ")[[1]]
#'
#' @export
#'
calc_counts <- function(dt,
                        target,
                        target_name = target,
                        treat,
                        indent = nbsp(n = 4L),
                        .total_dt = NULL,
                        pct_dec = 1) {

  stopifnot(
    is.data.frame(dt),
    is_string(target),
    is_string(target_name),
    is_string(treat),
    is_string(indent),
    is.null(.total_dt) || is.data.frame(.total_dt)
  )

  if (is.null(pct_dec)) {
    pct_dec <- 1
  }

  dt <- maybe_copy_dt(x = dt)
  counts_by_grp <- dt_count(dt = dt,
                            treatment = treat,
                            stats = target)

  if (!is.null(.total_dt)) {
    .total_dt <- maybe_copy_dt(x = .total_dt)
    counts_by_trt <- dt_count(.total_dt, treatment = treat, .name = "total")
    counts_by_grp <- counts_by_grp[counts_by_trt, on = "treatment"]
    counts_by_grp$n <- format_n_pct(
      n = counts_by_grp$n,
      pct = 100 * counts_by_grp$n / counts_by_grp$total,
      .pct_digits = pct_dec
    )
    j <- dot_wrap(c("treatment", "stats", "n"))
    counts_by_grp <- counts_by_grp[, j, env = list(j = j)]
  }

  counts_by_grp <- data.table::dcast(
    counts_by_grp,
    stats::as.formula("stats ~ treatment"),
    value.var = "n",
    fill = 0
  )

  header <- c(target_name, rep(list(""), times = ncol(counts_by_grp) - 1L))
  counts_by_grp[,  `:=`(stats = paste0(indent, as.character(counts_by_grp$stats)))]
  counts_by_grp <- rbind(header, counts_by_grp)

  list(counts_by_grp)
}


#' Calculate summary statistics for a variable
#'
#' [calc_stats()] calculates summary statistics for a variable on groups. This
#' is a generic function; note that it dispatches based on the class of
#' `target` (second argument), not `dt` (first argument).
#'
#' @inheritParams calc_desc
#' @inheritParams calc_counts
#' @param ... Additional arguments passed to other methods
#'
#' @returns A `data.table` of summary statistics. The format depends on the
#' type of the `target` variable:
#'
#' - If the `target` variable is categorical, i.e. type `character`, `factor`
#' or `logical` then the output is that of [calc_counts()].
#'
#' - If the `target` variable is numeric, then the output is that of
#' [calc_desc()].
#'
#' @examples
#' # Calculate summary statistics of a numeric variable, e.g. `AGE`.
#' calc_stats(dt = adsl, "AGE", treat = "ARM")[[1]]
#'
#' # Calculate summary statistics of a categorical variable, e.g. `SEX`.
#' calc_stats(dt = adsl, "SEX", treat = "ARM")[[1]]
#'
#' @export
calc_stats <- function(dt,
                       target,
                       treat,
                       ...,
                       target_name = target,
                       indent = nbsp(n = 4L),
                       .total_dt = NULL,
                       pct_dec = NULL) {
  dt <- maybe_copy_dt(x = dt)
  UseMethod("calc_stats", dt[[target]])
}

#' @export
calc_stats.numeric <- function(dt,
                               target,
                               treat,
                               ...,
                               target_name = target,
                               indent = nbsp(n = 4L),
                               pct_dec = NULL,
                               inc_missing = TRUE,
                               src_dec = NULL,
                               max_dec = 4L) {
  calc_desc(
    dt,
    target = target,
    treat = treat,
    target_name = target_name,
    indent = indent,
    inc_missing = inc_missing,
    pct_dec = pct_dec,
    src_dec = src_dec,
    max_dec = max_dec
  )
}

#' @export
calc_stats.character <- function(dt,
                                 target,
                                 treat,
                                 ...,
                                 target_name = target,
                                 indent = nbsp(n = 4L),
                                 .total_dt = NULL,
                                 pct_dec = 1) {
  calc_counts(
    dt = dt,
    target = target,
    target_name = target_name,
    treat = treat,
    indent = indent,
    .total_dt = .total_dt,
    pct_dec = pct_dec
  )
}

#' @export
calc_stats.factor <- function(dt,
                              target,
                              treat,
                              ...,
                              target_name = target,
                              indent = nbsp(n = 4L),
                              .total_dt = NULL,
                              pct_dec = 1) {
  calc_counts(
    dt = dt,
    target = target,
    target_name = target_name,
    treat = treat,
    indent = indent,
    .total_dt = .total_dt,
    pct_dec = pct_dec
  )
}

#' @export
calc_stats.logical <- function(dt,
                               target,
                               treat,
                               ...,
                               target_name = target,
                               indent = nbsp(n = 4L),
                               .total_dt = NULL,
                               pct_dec = 1) {
  calc_counts(
    dt = dt,
    target = target,
    target_name = target_name,
    treat = treat,
    indent = indent,
    .total_dt = .total_dt,
    pct_dec = pct_dec
  )
}

#' @export
calc_stats.default <- function(dt, target, ...) {
  target_class <- class(dt[[target]])
  stop("`cal_stats()` does not support dispatch on `target` variables of class ", target_class, ".")
}
