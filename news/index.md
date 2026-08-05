# Changelog

## dtlg 0.2.1

### Bug fixes

- event_count(): a category with zero matching subjects now renders with
  its label and a 0 count instead of an NA row label. v0.2.0 fixed the
  0-row crash but assigned the target via rep(label, nrow(x)) (a
  character column); at zero rows level_set()/dt_count() had no value to
  label the row. Using factor(rep(label, nrow(x)), levels = label) keeps
  the label as a factor level.

## dtlg 0.2.0

Maintained fork of AscentSoftware/dtlg (MIT), forked at commit dffe23d.

### Bug fixes

- [`event_count()`](https://AscentSoftware.github.io/dtlg/reference/event_count.md)
  no longer errors when the filtered subset has zero rows. The v0.1.1
  refactor (commit 331060c) replaced a 0-row-safe data.table `:=`
  assignment with base `[[<-`, which throws “replacement has 1 row, data
  has 0” on an empty table. Any disposition/screen-status category with
  no subjects (common under a SUBJID filter) crashed instead of
  rendering as a zero-count row. The assignment is now length-matched
  via `rep(label, nrow(x))`.

## dtlg 0.1.1

### Bug fixes and behaviour changes

- [`AET01_table()`](https://AscentSoftware.github.io/dtlg/reference/AET01_table.md):
  the row label for AE-related withdrawals has been shortened from
  “Total number of patients withdrawn from study due to an AE” to “Total
  number of patients withdrawn due to an AE”, for consistency with the
  other terse event labels in the same table. Code that matches this
  label by string equality (e.g. snapshot tests) will need to be
  updated.

### Documentation

- The README and the “Getting started” article now set a wider print
  width and display the full AET01 table rather than truncating row
  labels.

## dtlg 0.1.0

CRAN release: 2026-04-29

### New features

- [`summary_table()`](https://AscentSoftware.github.io/dtlg/reference/summary_table.md),
  [`summary_table_by()`](https://AscentSoftware.github.io/dtlg/reference/summary_table_by.md)
  and
  [`summary_table_by_targets()`](https://AscentSoftware.github.io/dtlg/reference/summary_table_by_targets.md)
  gain an `inc_missing` argument controlling how the “Missing” row is
  rendered for numeric targets: `TRUE` (default) always shows it, `NA`
  shows it only when missing values are present, and `FALSE` suppresses
  it. Plumbed through to
  [`calc_desc()`](https://AscentSoftware.github.io/dtlg/reference/calc_desc.md)
  and
  [`calc_stats()`](https://AscentSoftware.github.io/dtlg/reference/calc_stats.md).
- [`summary_table_by()`](https://AscentSoftware.github.io/dtlg/reference/summary_table_by.md)
  and
  [`summary_table_by_targets()`](https://AscentSoftware.github.io/dtlg/reference/summary_table_by_targets.md)
  gain a `sep` argument to set the separator between the heading and
  group labels when grouping by more than one variable in `rows_by`
  (defaults to `"."`).

### Bug fixes and behaviour changes

- [`calc_desc()`](https://AscentSoftware.github.io/dtlg/reference/calc_desc.md):
  the `n` row now reports the count of non-missing values rather than
  the total row count (`.N`), so `n` and the `Missing` row are now
  consistent.
- [`summary_table_by_targets()`](https://AscentSoftware.github.io/dtlg/reference/summary_table_by_targets.md):
  removed the spurious “target needs to be length 2” message; multiple
  target variables are now properly supported and covered by tests.

### Infrastructure and tooling

- Adopted `lintr` with default linters across the package and added a
  `lint.yaml` GitHub Actions workflow.
- Added a code-coverage workflow that posts a coverage summary as a
  comment on pull requests, gated on `pull_request` events to avoid
  duplicate runs.
- Expanded the test suite – new tests for
  [`AET01_table()`](https://AscentSoftware.github.io/dtlg/reference/AET01_table.md),
  the rounding helpers,
  [`tern_summary_table()`](https://AscentSoftware.github.io/dtlg/reference/tern_summary_table.md),
  and additional `summary_table*()` cases (multiple targets,
  missing-value handling) – raising overall coverage.

### Documentation and metadata

- Reorganised maintainership and contact details: maintainer e-mails
  moved to the `acuityanalytics.com` domain and copyright holder updated
  to Acuity Analytics.
- Documentation cleanup for `dt_count()`, `dt_summarise()` and the
  `summary_table*()` family; minor README and benchmarks article fixes.

## dtlg 0.0.3

CRAN release: 2026-01-12

- Removed dependency of dtlg.data in the benchmark vignette

## dtlg 0.0.2

CRAN release: 2025-09-23

- Initial CRAN submission.
