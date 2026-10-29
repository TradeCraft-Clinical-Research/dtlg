# Print a `dtlg` table

A convenience wrapper around
[`print()`](https://rdrr.io/r/base/print.html) for printing `dtlg`
tables with consistent formatting options.

## Usage

``` r
print_dtlg(
  dt,
  row.names = FALSE,
  trunc.cols = TRUE,
  class = FALSE,
  nrows = Inf,
  justify = "left"
)
```

## Arguments

- dt:

  A `dtlg` table, typically a `data.frame` or `data.table`.

- row.names:

  If `TRUE`, row indices will be printed alongside `x`.

- trunc.cols:

  If `TRUE`, only the columns that can be printed in the console without
  wrapping the columns to new lines will be printed (similar to
  `tibbles`).

- class:

  If `TRUE`, the resulting output will include above each column its
  storage class (or a self-evident abbreviation thereof). When combined
  with `col.names="auto"` and tables \>20 rows, classes will also appear
  at the bottom.

- nrows:

  The number of rows which will be printed before truncation is
  enforced.

- justify:

  String. Column alignment; one of `"left"`, `"right"`, `"centre"`, or
  `"none"`. Defaults to `"left"`.

## Value

Invisibly returns the printed object.

## Examples

``` r
calc_stats(dt = adsl, "AGE", treat = "ARM", indent = "  ")[[1]] |>
  print_dtlg()
#>        stats   A: Drug X  B: Placebo C: Combination
#>  AGE                                               
#>    n         134         134            132        
#>    Mean (SD) 33.8 (6.55) 35.4 (7.90)    35.4 (7.72)
#>    Median    33.0        35.0           35.0       
#>    Min, Max  21, 50      21, 62         20, 69     
#>    Missing   0           0              0          
```
