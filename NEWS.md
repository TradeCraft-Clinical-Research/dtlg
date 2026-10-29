# dtlg 0.3.1

## Improvements

* `summary_table_by()` and `summary_table_by_targets()` gain `src_dec` to pass the
  number of decimals of the source values explicitly (used when `pct_dec` is
  `NULL`), e.g. the precision of `AVAL` for a change-from-baseline target, or of
  all records of a lab parameter before any filtering.
* With a single `rows_by` variable (e.g. the visits of one lab parameter), the
  source precision is now taken across the whole of `dt` instead of per visit, so
  every visit is shown with the same decimals. With several `rows_by` variables it
  is still taken per value of the first one (e.g. per parameter).

# dtlg 0.3.0

## Breaking changes

* Continuous summaries (`calc_desc()`, `calc_stats()` on numeric targets,
  `summary_table()`, `summary_table_by()`, `summary_table_by_targets()`) now
  default to `pct_dec = NULL`: the decimals of each statistic are derived from
  the precision of the source values (the largest number of decimals found in
  the data, see `source_decimals()`). The mean and median get one more decimal
  than the source, the standard deviation two more, and the minimum and maximum
  the same as the source. `summary_table_by()` takes the precision across all
  splits of the first `rows_by` variable (e.g. all visits of a lab parameter).
  Passing a number to `pct_dec` restores the previous behaviour (one precision
  for every statistic).
* The median is now formatted text (`"5.0"`) instead of a bare number, so
  trailing zeros are kept.

## Bug fixes

* Percentages, means, SDs and min/max are now rounded half away from zero, as
  SAS does. Previously `sprintf()` rounded exact ties to even and values such as
  `6.35` (binary `6.3499999...`) down, so `1/16` (6.25%) was shown as `6.2%`
  where SAS gives `6.3%`.

## New functions

* `round_half_up()`, `format_fixed()` and `source_decimals()`.

# dtlg 0.2.2

## Bug fixes

* `event_count()` (and therefore `multi_event_true()` and `event_count_by()`)
  now always labels its output row with the supplied `label`, and renders
  zero-count events as "0" across every treatment arm, even when the filtered
  subset has zero rows.

  The v0.1.x refactor rebuilt `event_count()` on top of `summary_table()`,
  which *derives* the row label and the arm columns from the observed data
  rather than assigning them. When `.filters` matched no rows (e.g. a
  disposition reason with no subjects under a subject-level filter) the
  derivation collapsed: `dt_count()`'s key space became empty, the count row
  was lost, and the denominator join produced a row with an <NA> label and
  blank counts. The pre-refactor vendor version (0.0.1) avoided this by
  assigning `stats := label` directly and counting against a fixed set of
  treatment arms.

  This release restores that behaviour: the treatment and label columns are
  pinned to a stable level set taken from the denominator population before
  summarising, and the output row label is assigned from `label` as a final
  safeguard.

# dtlg 0.2.1

## Bug fixes

* event_count(): a category with zero matching subjects now renders with its
  label and a 0 count instead of an NA row label. v0.2.0 fixed the 0-row crash
  but assigned the target via rep(label, nrow(x)) (a character column); at zero
  rows level_set()/dt_count() had no value to label the row. Using
  factor(rep(label, nrow(x)), levels = label) keeps the label as a factor level.

# dtlg 0.2.0

Maintained fork of AscentSoftware/dtlg (MIT), forked at commit dffe23d.

## Bug fixes

* `event_count()` no longer errors when the filtered subset has zero rows.
The v0.1.1 refactor (commit 331060c) replaced a 0-row-safe data.table `:=`
assignment with base `[[<-`, which throws "replacement has 1 row, data
  has 0" on an empty table. Any disposition/screen-status category with no
subjects (common under a SUBJID filter) crashed instead of rendering as a
zero-count row. The assignment is now length-matched via
`rep(label, nrow(x))`.

# dtlg 0.1.1

## Bug fixes and behaviour changes

* `AET01_table()`: the row label for AE-related withdrawals has been
  shortened from "Total number of patients withdrawn from study due to an
  AE" to "Total number of patients withdrawn due to an AE", for
  consistency with the other terse event labels in the same table. Code
  that matches this label by string equality (e.g. snapshot tests) will
  need to be updated.

## Documentation

* The README and the "Getting started" article now set a wider print
  width and display the full AET01 table rather than truncating row
  labels.

# dtlg 0.1.0

## New features

* `summary_table()`, `summary_table_by()` and `summary_table_by_targets()` gain
  an `inc_missing` argument controlling how the "Missing" row is rendered for
  numeric targets: `TRUE` (default) always shows it, `NA` shows it only when
  missing values are present, and `FALSE` suppresses it. Plumbed through to
  `calc_desc()` and `calc_stats()`.
* `summary_table_by()` and `summary_table_by_targets()` gain a `sep` argument
  to set the separator between the heading and group labels when grouping by
  more than one variable in `rows_by` (defaults to `"."`).

## Bug fixes and behaviour changes

* `calc_desc()`: the `n` row now reports the count of non-missing values
rather than the total row count (`.N`), so `n` and the `Missing` row are now
consistent.
* `summary_table_by_targets()`: removed the spurious "target needs to be
  length 2" message; multiple target variables are now properly supported and
  covered by tests.

## Infrastructure and tooling

* Adopted `lintr` with default linters across the package and added a
`lint.yaml` GitHub Actions workflow.
* Added a code-coverage workflow that posts a coverage summary as a comment on
  pull requests, gated on `pull_request` events to avoid duplicate runs.
* Expanded the test suite -- new tests for `AET01_table()`, the rounding
  helpers, `tern_summary_table()`, and additional `summary_table*()` cases
  (multiple targets, missing-value handling) -- raising overall coverage.

## Documentation and metadata

* Reorganised maintainership and contact details: maintainer e-mails moved to
  the `acuityanalytics.com` domain and copyright holder updated to Acuity
  Analytics.
* Documentation cleanup for `dt_count()`, `dt_summarise()` and the
  `summary_table*()` family; minor README and benchmarks article fixes.

# dtlg 0.0.3

* Removed dependency of dtlg.data in the benchmark vignette

# dtlg 0.0.2

* Initial CRAN submission.
