# Create a summary table using multiple rows for grouping on one target column

Create a summary table using multiple rows for grouping on one target
column

## Usage

``` r
summary_table_by(
  dt,
  target,
  treat,
  rows_by,
  indent = nbsp(n = 4L),
  .total_dt = dt,
  pct_dec = NULL,
  treat_order = NULL,
  skip_absent = TRUE,
  sep = "."
)
```

## Arguments

- dt:

  A `data.frame` containing, at least, the variables indicated in
  `target` and `treat`.

- target:

  Target variable passed as a string for which summary statistics are to
  be calculated.

- treat:

  A string indicating the grouping variable, e.g. the variable
  specifying the treatment population.

- rows_by:

  string, grouping variable to split events by.

- indent:

  A string to be used as indentation of summary statistics labels.
  Defaults to four HTML non-breaking spaces (`&nbsp;`).

- .total_dt:

  Separate table from `dt` from which to derive total counts per group.

- pct_dec:

  Decimal places for reported figures. The default, `NULL`, derives the
  decimals of each statistic from the precision of the source values
  (see `src_dec`): mean and median one more decimal than the source,
  standard deviation two more, minimum and maximum the same as the
  source. A number overrides this and is used for every statistic (the
  previous behaviour).

- treat_order:

  Customise the column order of the output table.

- skip_absent:

  Whether to ignore variables passed in `treat_order` that are absent
  from `dt`. Default is `TRUE`; `FALSE` will throw an error in case
  there are missing variables.

- sep:

  character string to separate the terms

## Value

The same output as
[`summary_table()`](https://AscentSoftware.github.io/dtlg/reference/summary_table.md)
except that folded by variables indicated in `rows_by`.

## Examples

``` r
summary_table_by(
  adlb,
  target = "AVAL",
  treat = "ARM",
  rows_by = c("PARAM","AVISIT")
)
#> [[1]]
#>                                                          stats
#>                                                         <char>
#>   1:                      Alanine Aminotransferase Measurement
#>   2:                         &nbsp;&nbsp;&nbsp;&nbsp;SCREENING
#>   3:         &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;n
#>   4: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Mean (SD)
#>   5:    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Median
#>  ---                                                          
#> 125:         &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;n
#> 126: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Mean (SD)
#> 127:    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Median
#> 128:  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Min, Max
#> 129:   &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Missing
#>                A: Drug X          B: Placebo      C: Combination
#>                   <char>              <char>              <char>
#>   1:                <NA>                <NA>                <NA>
#>   2:                                                            
#>   3:                 134                 134                 132
#>   4: 18.18741 (8.523147) 19.32020 (9.818815) 18.45257 (9.112056)
#>   5:            17.63222            18.10897            17.55179
#>  ---                                                            
#> 125:                 134                 134                 132
#> 126:  2.90724 (0.089662)  2.89914 (0.103584)  2.89671 (0.104742)
#> 127:             2.91348             2.91676             2.90978
#> 128:      2.5955, 3.0845      2.6175, 3.1276      2.6081, 3.1274
#> 129:                   0                   0                   0
#> 
```
