# Calculate summary statistics for a variable

`calc_stats()` calculates summary statistics for a variable on groups.
This is a generic function; note that it dispatches based on the class
of `target` (second argument), not `dt` (first argument).

## Usage

``` r
calc_stats(
  dt,
  target,
  treat,
  ...,
  target_name = target,
  indent = nbsp(n = 4L),
  .total_dt = NULL,
  pct_dec = NULL
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

- ...:

  Additional arguments passed to other methods

- target_name:

  Heading for the target variable as a string. Defaults to `target`.

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

## Value

A `data.table` of summary statistics. The format depends on the type of
the `target` variable:

- If the `target` variable is categorical, i.e. type `character`,
  `factor` or `logical` then the output is that of
  [`calc_counts()`](https://AscentSoftware.github.io/dtlg/reference/calc_counts.md).

- If the `target` variable is numeric, then the output is that of
  [`calc_desc()`](https://AscentSoftware.github.io/dtlg/reference/calc_desc.md).

## Examples

``` r
# Calculate summary statistics of a numeric variable, e.g. `AGE`.
calc_stats(dt = adsl, "AGE", treat = "ARM")[[1]]
#>                                stats   A: Drug X  B: Placebo C: Combination
#>                               <char>      <char>      <char>         <char>
#> 1:                               AGE                                       
#> 2:         &nbsp;&nbsp;&nbsp;&nbsp;n         134         134            132
#> 3: &nbsp;&nbsp;&nbsp;&nbsp;Mean (SD) 33.8 (6.55) 35.4 (7.90)    35.4 (7.72)
#> 4:    &nbsp;&nbsp;&nbsp;&nbsp;Median        33.0        35.0           35.0
#> 5:  &nbsp;&nbsp;&nbsp;&nbsp;Min, Max      21, 50      21, 62         20, 69
#> 6:   &nbsp;&nbsp;&nbsp;&nbsp;Missing           0           0              0

# Calculate summary statistics of a categorical variable, e.g. `SEX`.
calc_stats(dt = adsl, "SEX", treat = "ARM")[[1]]
#>                        stats A: Drug X B: Placebo C: Combination
#>                       <char>    <char>     <char>         <char>
#> 1:                       SEX                                    
#> 2: &nbsp;&nbsp;&nbsp;&nbsp;F        79         82             70
#> 3: &nbsp;&nbsp;&nbsp;&nbsp;M        55         52             62
```
