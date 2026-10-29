# Round half away from zero

`round_half_up()` rounds `x` to `digits` decimal places, rounding a
value that lies exactly half-way (e.g. `6.25` to one decimal place)
**away from zero**, which is how SAS rounds and what most readers of a
clinical table expect. Base
[`round()`](https://rdrr.io/r/base/Round.html) (and
[`sprintf()`](https://rdrr.io/r/base/sprintf.html)) round such ties to
the *even* digit instead (`6.25` becomes `6.2`), and values that are
ties in decimal but not in binary (e.g. `6.35`, stored as
`6.3499999...`) are rounded down.

## Usage

``` r
round_half_up(x, digits = 0L)
```

## Arguments

- x:

  A numeric vector. `NA` values are returned as `NA`.

- digits:

  A single non-negative number of decimal places. Defaults to `0`.

## Value

A numeric vector of the same length as `x`.

## Details

A small tolerance (`1e-9`, or a few machine epsilons for very large
values) absorbs binary representation error, so any value that is a tie
in decimal is treated as a tie. For percentages of whole counts this is
exact for any realistic denominator.

## Examples

``` r
round_half_up(c(6.25, 6.35, 0.5, 2.5, -2.5), 1)
#> [1]  6.3  6.4  0.5  2.5 -2.5
round_half_up(c(0.5, 1.5, 2.5, -2.5))
#> [1]  1  2  3 -3
# Base R rounds ties to even
round(c(0.5, 1.5, 2.5, -2.5))
#> [1]  0  2  2 -2
```
