# Format numbers with a fixed number of decimals (half away from zero)

`format_fixed()` formats `x` as strings with exactly `digits` decimal
places after rounding with
[`round_half_up()`](https://AscentSoftware.github.io/dtlg/reference/round_half_up.md),
so that, for example, `6.25` becomes `"6.3"` and `5` becomes `"5.0"`.

## Usage

``` r
format_fixed(x, digits = 1L)
```

## Arguments

- x:

  A numeric vector.

- digits:

  A single non-negative number of decimal places. Defaults to `1`.

## Value

A character vector; `NA` values give `NA_character_`.

## Examples

``` r
format_fixed(c(6.25, 5, 12.345, NA), digits = 1)
#> [1] "6.3"  "5.0"  "12.3" NA    
format_fixed(0.0625 * 100, digits = 1)
#> [1] "6.3"
```
