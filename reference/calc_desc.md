# Calculate descriptive summary statistics for a numeric variable

`calc_desc()` summarises a numeric variable (`target`) by another
(`treat`) and reports summary statistics in clinical trial reporting
format. The following statistics are calculated for `target`, per group,
i.e. by variable `treat` levels:

- `n`: number of observations

- `Mean (SD)`: mean and standard deviation of `target`

- `Median`: median of `target`

- `Min, Max`: minimum and maximum of `target`

- `Missing`: number of missing `target` values

## Usage

``` r
calc_desc(
  dt,
  target,
  target_name = target,
  treat,
  indent = nbsp(n = 4L),
  pct_dec = NULL,
  inc_missing = TRUE,
  src_dec = NULL,
  max_dec = 4L
)
```

## Arguments

- dt:

  A `data.frame` containing, at least, the variables indicated in
  `target` and `treat`.

- target:

  Target variable passed as a string for which summary statistics are to
  be calculated.

- target_name:

  Heading for the target variable as a string. Defaults to `target`.

- treat:

  A string indicating the grouping variable, e.g. the variable
  specifying the treatment population.

- indent:

  A string to be used as indentation of summary statistics labels.
  Defaults to four HTML non-breaking spaces (`&nbsp;`).

- pct_dec:

  Decimal places for reported figures. The default, `NULL`, derives the
  decimals of each statistic from the precision of the source values
  (see `src_dec`): mean and median one more decimal than the source,
  standard deviation two more, minimum and maximum the same as the
  source. A number overrides this and is used for every statistic (the
  previous behaviour).

- inc_missing:

  Toggle for including the "Missing" row:

  `TRUE`

  :   (default) The Missing row is always displayed

  `NA`

  :   The Missing row is only displayed if any missing values are
      present

  `FALSE`

  :   The Missing row is never included in the table

- src_dec:

  Number of decimals of the source values, used when `pct_dec` is
  `NULL`. Defaults to the largest number of decimals found in `target`
  (see
  [`source_decimals()`](https://AscentSoftware.github.io/dtlg/reference/source_decimals.md)).
  Pass it explicitly when the precision should be taken from a wider set
  of data than `dt`, e.g. all visits of a lab parameter.

- max_dec:

  Cap on the decimals found in `target` when `src_dec` is not given.
  Defaults to `4`.

## Value

A list containing a `data.table` formatted as follows:

- First column is named `stats` and contains the target variable name
  indicated in `target` in the first row. Subsequent rows contain the
  summarised statistics labels.

- Other columns are for the levels of the grouping variable (`treat`).

- All columns are of character type.

This table is structured for easy integration with Shiny output widgets.

## Examples

``` r
# Calculate summary statistics for the age of the subjects in each region.
calc_desc(dt = adsl, "AGE", treat = "REGION1")[[1]]
#>                                stats      Africa        Asia     Eurasia
#>                               <char>      <char>      <char>      <char>
#> 1:                               AGE                                    
#> 2:         &nbsp;&nbsp;&nbsp;&nbsp;n          26         268          19
#> 3: &nbsp;&nbsp;&nbsp;&nbsp;Mean (SD) 32.3 (7.69) 34.6 (6.91) 35.9 (8.33)
#> 4:    &nbsp;&nbsp;&nbsp;&nbsp;Median        31.0        34.0        36.0
#> 5:  &nbsp;&nbsp;&nbsp;&nbsp;Min, Max      20, 50      21, 58      25, 58
#> 6:   &nbsp;&nbsp;&nbsp;&nbsp;Missing           0           0           0
#>          Europe North America South America
#>          <char>        <char>        <char>
#> 1:                                         
#> 2:            9            48            30
#> 3: 38.4 (16.09)   36.2 (6.76)   36.1 (8.10)
#> 4:         30.0          35.0          35.5
#> 5:       26, 69        24, 57        24, 64
#> 6:            0             0             0

# Calculate summary statistics for biomarker 1 in each of the three arms
# (`ARM`).
calc_desc(dt = adsl, "BMRKR1", treat = "ARM")[[1]]
#>                                stats          A: Drug X         B: Placebo
#>                               <char>             <char>             <char>
#> 1:                            BMRKR1                                      
#> 2:         &nbsp;&nbsp;&nbsp;&nbsp;n                134                134
#> 3: &nbsp;&nbsp;&nbsp;&nbsp;Mean (SD) 5.96986 (3.554098) 5.69851 (3.306731)
#> 4:    &nbsp;&nbsp;&nbsp;&nbsp;Median            5.38509            4.80596
#> 5:  &nbsp;&nbsp;&nbsp;&nbsp;Min, Max    0.4056, 17.6723    0.6484, 14.2374
#> 6:   &nbsp;&nbsp;&nbsp;&nbsp;Missing                  0                  0
#>        C: Combination
#>                <char>
#> 1:                   
#> 2:                132
#> 3: 5.61791 (3.493994)
#> 4:            4.61109
#> 5:    0.1654, 21.3934
#> 6:                  0
```
