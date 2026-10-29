reorder_cols <- function(dt, cols, before_cols = "stats", skip_absent = TRUE) {

  cols %||% return(dt)

  all_cols <- colnames(dt)
  cols_missing <- sort(setdiff(all_cols, cols))
  new_cols <- unique(c(before_cols, cols, cols_missing))
  data.table::setcolorder(dt, new_cols, skip_absent = skip_absent)[]
}

#' Summary Table
#'
#' [summary_table()] summarises clinical variables into a report table using
#' `data.table` as backend.
#'
#' @inheritParams calc_stats
#' @param treat_order Customise the column order of the output table.
#' @param skip_absent Whether to ignore variables passed in `treat_order` that
#'   are absent from `dt`. Default is `TRUE`; `FALSE` will throw an error in
#'   case there are missing variables.
#' @param inc_missing If any of the `target` variables are numeric, then used
#' as a toggle to determine whether or not "Missing" appears in the summary stats:
#' \describe{
#' \item{`TRUE`}{(default) The Missing row is always displayed}
#' \item{`NA`}{The Missing row is only displayed if any missing values are present}
#' \item{`FALSE`}{The Missing row is never included in the table}
#' }
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
#' @seealso [tern_summary_table()]
#'
#' @examples
#' dmg_vars <- c("AGE", "RACE", "ETHNIC")
#' dmg_var_lbls <- c("Age (yr)", "Race", "Ethnicity")
#'
#' # Demographics table (DMT01)
#' summary_table(
#'   adsl,
#'   target = dmg_vars,
#'   treat = 'ARM',
#'   target_name = dmg_var_lbls
#' )
#'
#' # Demographics table (DMT01) with continuous variable (e.g., BMRKR1)
#' summary_table(
#'   adsl,
#'   target = c(dmg_vars, "BMRKR1"),
#'   treat = 'ARM',
#'   target_name = c(dmg_var_lbls, "Biomarker 1")
#' )
#'
#' @export
#'
summary_table <- function(dt,
                          target,
                          treat,
                          target_name = target,
                          indent = nbsp(n = 4L),
                          .total_dt = dt,
                          pct_dec = NULL,
                          treat_order = NULL,
                          skip_absent = TRUE,
                          inc_missing = TRUE) {

  stopifnot(length(target) >= length(target_name), length(target) >= length(indent))
  vct_args <- vctrs::vec_recycle_common(target = target, target_name = target_name, indent = indent)
  scl_args <- list( # nolint: object_usage_linter
    dt = dt,
    treat = treat,
    .total_dt = .total_dt,
    pct_dec = pct_dec,
    inc_missing = inc_missing
  )

  summaries <- with(
    vct_args,
    expr = mapply(
      FUN = calc_stats,
      target = target,
      target_name = target_name,
      indent = indent,
      MoreArgs = scl_args
    )
  )

  summaries |>
    data.table::rbindlist(use.names = TRUE) |>
    reorder_cols(cols = treat_order, skip_absent = skip_absent)
}

#' Create a summary table using multiple rows for grouping on one target column
#'
#' @inheritParams summary_table
#' @param rows_by string, grouping variable to split events by.
#' @param sep character string to separate the terms
#' @param src_dec Number of decimals of the source values, used when `pct_dec`
#'   is `NULL`. By default it is derived from the data (see [source_decimals()]):
#'   across the splits of the first `rows_by` variable when there are several, or
#'   across the whole of `dt` when there is only one. Pass it to use the precision
#'   of a wider set of data, e.g. all records of a lab parameter before filtering,
#'   or the precision of `AVAL` for a change-from-baseline target.
#'
#' @returns The same output as [summary_table()] except that folded by variables
#' indicated in `rows_by`.
#' @export
#'
#' @examples
#' summary_table_by(
#'   adlb,
#'   target = "AVAL",
#'   treat = "ARM",
#'   rows_by = c("PARAM","AVISIT")
#' )
summary_table_by <- function(dt,
                             target,
                             treat,
                             rows_by,
                             indent = nbsp(n = 4L),
                             .total_dt = dt,
                             pct_dec = NULL,
                             treat_order = NULL,
                             skip_absent = TRUE,
                             sep = ".",
                             src_dec = NULL) {
  dt <- maybe_copy_dt(x = dt)

  # Source precision (only used when `pct_dec` is NULL and the target is numeric):
  # - `src_dec` given: used for every row;
  # - several `rows_by`: taken across all splits of the first one (e.g. all visits
  #   of one lab parameter), so every visit of a parameter has the same decimals;
  # - one `rows_by` (e.g. just the visit of a single parameter): taken across the
  #   whole of `dt`.
  src_dec_rows <- NULL
  dec_by <- NULL
  if (is.null(pct_dec) && is.numeric(dt[[target]])) {
    if (is.null(src_dec) && length(rows_by) > 1L) {
      dec_by <- tapply(dt[[target]], as.character(dt[[rows_by[1L]]]), source_decimals)
    } else if (is.null(src_dec)) {
      src_dec <- source_decimals(dt[[target]])
    }
  }

  dt <- split(droplevels(dt), by = rows_by, drop = TRUE, sorted = TRUE)
  label <- names(dt)
  if (!is.null(dec_by)) {
    first <- vapply(dt, function(x) as.character(x[[rows_by[1L]]][1L]), character(1L))
    src_dec_rows <- as.list(unname(dec_by[first]))
  } else if (!is.null(src_dec)) {
    src_dec_rows <- rep(list(src_dec), length(dt))
  }

  if (length(rows_by) > 1) {
    label <- strsplit(label, ".", fixed = TRUE)
    heading_full <- lapply(X = label, function(x) {
      x[1]
    })
    heading <- unique(heading_full)
    label <- lapply(label, \(x) paste(x[-1L], collapse = sep))
    label <- paste0(indent, label)
    indent <- paste0(indent, indent)
  }

  summary_split <- if (is.null(src_dec_rows)) {
    mapply(
      calc_stats,
      dt = dt,
      target = target,
      target_name = label,
      treat = treat,
      indent = indent,
      MoreArgs = list(pct_dec = pct_dec)
    )
  } else {
    mapply(
      calc_stats,
      dt = dt,
      target = target,
      target_name = label,
      treat = treat,
      indent = indent,
      src_dec = src_dec_rows,
      MoreArgs = list(pct_dec = pct_dec)
    )
  }

  if (length(rows_by) > 1) {
    x <- 0
    for (i in seq_along(heading)) {
      y = sum(heading_full %in% heading[i])
      summary_split <- append(
        summary_split,
        list(data.table::data.table(stats = heading[[i]])),
        after = x
      )
      x <- x + y + 1
    }
  }

  summary_split |>
    data.table::rbindlist(use.names = TRUE, fill = TRUE) |>
    reorder_cols(cols = treat_order, skip_absent = skip_absent) |>
    list()
}

#' Create a summary table using multiple rows for grouping on two target column
#' ideal for creating change from baseline tables
#'
#' @param dt table to perform function on
#' @param target vector of column names desired to obtain information on
#' @param treat string of treatment variable used for splitting / grouping data
#' @param rows_by string, grouping variable to split events by.
#' @param indent indent to be used for display and formatting purposes
#' @param .total_dt optional table for total counts to be derived
#' @param pct_dec decimal places for percentages (and, if a number, for every
#'   continuous statistic). `NULL` (default): percentages use 1 decimal and
#'   continuous statistics are derived from the source precision, see
#'   [calc_desc()].
#' @param treat_order customise the column order of output table
#' @param skip_absent Logical, default `TRUE`. Passed to
#'   `data.table::setcolorder`, if `treat_order` includes columns not present in
#'   `dt`:
#' - `TRUE` will silently ignore them
#' - `FALSE` will throw an error
#' @param sep character string to separate the terms
#' @param src_dec Number of decimals of the source values, used when `pct_dec`
#'   is `NULL`. By default it is derived from the data (see [source_decimals()]):
#'   across the splits of the first `rows_by` variable when there are several, or
#'   across the whole of `dt` when there is only one. Pass it to use the precision
#'   of a wider set of data, e.g. all records of a lab parameter before filtering,
#'   or the precision of `AVAL` for a change-from-baseline target.
#'
#' @return data.table
#' @export
#'
#' @examples
#' adlb <- random.cdisc.data::cadlb |>
#'   dplyr::filter(AVISIT != "SCREENING")
#'
#' labs <- summary_table_by_targets(
#'   dt = adlb,
#'   target = c("AVAL", "CHG"),
#'   treat = "ARM",
#'   rows_by = c("PARAM", "AVISIT"),
#'   indent = "  "
#' )
summary_table_by_targets <- function(dt,
                                     target,
                                     treat,
                                     rows_by,
                                     indent = nbsp(n = 4L),
                                     .total_dt = NULL,
                                     pct_dec = NULL,
                                     treat_order = NULL,
                                     skip_absent = TRUE,
                                     sep = ".",
                                     src_dec = NULL) {
  .total_dt <- maybe_copy_dt(x = .total_dt)

  summary_tables <- mapply(
    summary_table_by,
    target = target,
    MoreArgs = list(
      dt = dt,
      treat = treat,
      rows_by = rows_by,
      indent = indent,
      .total_dt = .total_dt,
      pct_dec = pct_dec,
      treat_order = treat_order,
      skip_absent = skip_absent,
      sep = sep,
      src_dec = src_dec
    )
  )

  for (i in seq_along(summary_tables)) {
    data.table::setnames(
      summary_tables[[i]],
      old = -1L,
      new = paste(names(summary_tables[[i]])[-1L], target[i], sep = sep)
    )
  }

  data.table::cbindlist(
    c(
      list(summary_tables[[1]][, 1, with = FALSE]),
      lapply(
        seq(2, ncol(summary_tables[[1]])),
        \(i) data.table::cbindlist(lapply(summary_tables, \(dat) dat[, i, with = FALSE]))
      )
    )
  )
}
