# Number of decimal places in the source values

`source_decimals()` returns the largest number of decimal places that
the non-missing values of `x` actually use, e.g. `c(4.5, 4.25, 7)` has
two. It is meant to be computed on the raw analysis values (e.g. `AVAL`
of one lab parameter, across all treatment arms and visits) so that
summary statistics can be shown with a precision relative to the source
data.

## Usage

``` r
source_decimals(x, max_dec = 4L)
```

## Arguments

- x:

  A numeric vector. Non-finite values are ignored.

- max_dec:

  Largest number of decimals to report. Defaults to `4`.

## Value

A single integer, `0` when there is no finite value.

## Details

Numeric data does not keep trailing zeros (`4.50` is stored as `4.5`),
so the result is the precision *found in the data* and can understate
the precision of the collected values if no value shows a trailing zero.
Binary noise (e.g. `0.1 + 0.2`) is ignored. At most `max_dec` decimals
are reported, which stops derived values such as a calculated BMI from
producing very long numbers.

## Examples

``` r
source_decimals(c(4.5, 4.25, 7))
#> [1] 2
source_decimals(c(30, 35, NA))
#> [1] 0
source_decimals(c(0.1 + 0.2, 1))
#> [1] 1
```
