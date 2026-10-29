# Benchmarks

## Benchmark data

``` r

seed <- 42

adsl_small <- random.cdisc.data::radsl(N = 20000, seed = seed)
adsl_large <- random.cdisc.data::radsl(N = 1000000, seed = seed)
aesi <- dtlg::aesi
```

## Benchmarking demographics data

``` r

arm_var <- "ARM"
vars <- c(
  "AGE", "SEX", "RACE", "ETHNIC", "COUNTRY", "DTHFL", "BMRKR1",
  "REGION1", "BMRKR2"
)

bench::mark(
  tern_dmg_tab <- dtlg::tern_summary_table(
    adsl_large,
    target = vars,
    treat = arm_var
  ),
  dtlg_dmg_tab <- dtlg::summary_table(
    adsl_large,
    target = vars,
    treat = arm_var,
    indent = "",
    .total_dt = adsl_large
  ),
  iterations = 1L,
  check = FALSE
)
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
#> # A tibble: 2 × 6
#>   expression                            min  median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                        <bch:t> <bch:t>     <dbl> <bch:byt>    <dbl>
#> 1 tern_dmg_tab <- dtlg::tern_summa…   26.7s   26.7s    0.0374    8.08GB     1.95
#> 2 dtlg_dmg_tab <- dtlg::summary_ta… 433.7ms 433.7ms    2.31    814.64MB     2.31
dtlg::as_dtlg_table(tt = tern_dmg_tab)
#>                                         stats      A: Drug X     B: Placebo
#>                                        <char>         <char>         <char>
#>  1:                                       AGE                              
#>  2:                                         n         333924         333087
#>  3:                                 Mean (SD)     34.5 (7.1)     34.5 (7.1)
#>  4:                                    Median           34.0           34.0
#>  5:                                 Min - Max    20.0 - 84.0    20.0 - 86.0
#>  6:                                       SEX                              
#>  7:                                         n         333924         333087
#>  8:                                         F   173527 (52%)   173167 (52%)
#>  9:                                         M   160397 (48%)   159920 (48%)
#> 10:                                      RACE                              
#> 11:                                         n         333924         333087
#> 12:                                     ASIAN 184009 (55.1%) 183379 (55.1%)
#> 13:                 BLACK OR AFRICAN AMERICAN  76493 (22.9%)    76700 (23%)
#> 14:                                     WHITE  52983 (15.9%)  52948 (15.9%)
#> 15:          AMERICAN INDIAN OR ALASKA NATIVE     16823 (5%)   16435 (4.9%)
#> 16:                                  MULTIPLE    1367 (0.4%)    1304 (0.4%)
#> 17: NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER     978 (0.3%)    1004 (0.3%)
#> 18:                                     OTHER     615 (0.2%)     693 (0.2%)
#> 19:                                   UNKNOWN     656 (0.2%)     624 (0.2%)
#> 20:                                    ETHNIC                              
#> 21:                                         n         333924         333087
#> 22:                        HISPANIC OR LATINO    33527 (10%)   33122 (9.9%)
#> 23:                    NOT HISPANIC OR LATINO   267178 (80%)   266445 (80%)
#> 24:                              NOT REPORTED   19788 (5.9%)     20149 (6%)
#> 25:                                   UNKNOWN     13431 (4%)     13371 (4%)
#> 26:                                   COUNTRY                              
#> 27:                                         n         333924         333087
#> 28:                                       CHN 168262 (50.4%) 168213 (50.5%)
#> 29:                                       USA  41035 (12.3%)  40620 (12.2%)
#> 30:                                       BRA   25981 (7.8%)   25698 (7.7%)
#> 31:                                       PAK   26117 (7.8%)   26043 (7.8%)
#> 32:                                       NGA   25230 (7.6%)   25404 (7.6%)
#> 33:                                       RUS   17699 (5.3%)   17587 (5.3%)
#> 34:                                       JPN   15347 (4.6%)   15475 (4.6%)
#> 35:                                       GBR    8567 (2.6%)    8284 (2.5%)
#> 36:                                       CAN    4738 (1.4%)    4783 (1.4%)
#> 37:                                       CHE     948 (0.3%)     980 (0.3%)
#> 38:                                     DTHFL                              
#> 39:                                         n         333924         333087
#> 40:                                         N 278284 (83.3%) 277476 (83.3%)
#> 41:                                         Y  55640 (16.7%)  55611 (16.7%)
#> 42:                                    BMRKR1                              
#> 43:                                         n         333924         333087
#> 44:                                 Mean (SD)      6.0 (3.5)      6.0 (3.5)
#> 45:                                    Median            5.3            5.3
#> 46:                                 Min - Max     0.0 - 36.4     0.0 - 33.5
#> 47:                                   REGION1                              
#> 48:                                         n         333924         333087
#> 49:                                    Africa   25230 (7.6%)   25404 (7.6%)
#> 50:                                      Asia 209726 (62.8%)   209731 (63%)
#> 51:                                   Eurasia   17699 (5.3%)   17587 (5.3%)
#> 52:                                    Europe    8567 (2.6%)    8284 (2.5%)
#> 53:                             North America  45773 (13.7%)  45403 (13.6%)
#> 54:                             South America   25981 (7.8%)   25698 (7.7%)
#> 55:                                   Missing     948 (0.3%)     980 (0.3%)
#> 56:                                    BMRKR2                              
#> 57:                                         n         333924         333087
#> 58:                                       LOW 111579 (33.4%) 111021 (33.3%)
#> 59:                                    MEDIUM 111381 (33.4%) 111000 (33.3%)
#> 60:                                      HIGH 110964 (33.2%) 111066 (33.3%)
#>                                         stats      A: Drug X     B: Placebo
#>                                        <char>         <char>         <char>
#>     C: Combination
#>             <char>
#>  1:               
#>  2:         332989
#>  3:     34.5 (7.1)
#>  4:           34.0
#>  5:    20.0 - 89.0
#>  6:               
#>  7:         332989
#>  8: 172556 (51.8%)
#>  9: 160433 (48.2%)
#> 10:               
#> 11:         332989
#> 12: 183398 (55.1%)
#> 13:  76367 (22.9%)
#> 14:  53015 (15.9%)
#> 15:     16551 (5%)
#> 16:    1294 (0.4%)
#> 17:    1054 (0.3%)
#> 18:     644 (0.2%)
#> 19:     666 (0.2%)
#> 20:               
#> 21:         332989
#> 22:  33604 (10.1%)
#> 23:   266303 (80%)
#> 24:     19896 (6%)
#> 25:     13186 (4%)
#> 26:               
#> 27:         332989
#> 28: 168093 (50.5%)
#> 29:  40864 (12.3%)
#> 30:   25833 (7.8%)
#> 31:   25885 (7.8%)
#> 32:   25438 (7.6%)
#> 33:   17359 (5.2%)
#> 34:   15522 (4.7%)
#> 35:    8419 (2.5%)
#> 36:    4593 (1.4%)
#> 37:     983 (0.3%)
#> 38:               
#> 39:         332989
#> 40: 277339 (83.3%)
#> 41:  55650 (16.7%)
#> 42:               
#> 43:         332989
#> 44:      6.0 (3.5)
#> 45:            5.4
#> 46:     0.0 - 34.2
#> 47:               
#> 48:         332989
#> 49:   25438 (7.6%)
#> 50: 209500 (62.9%)
#> 51:   17359 (5.2%)
#> 52:    8419 (2.5%)
#> 53:  45457 (13.7%)
#> 54:   25833 (7.8%)
#> 55:     983 (0.3%)
#> 56:               
#> 57:         332989
#> 58: 110749 (33.3%)
#> 59: 111125 (33.4%)
#> 60: 111115 (33.4%)
#>     C: Combination
#>             <char>
dtlg_dmg_tab
#>                                         stats          A: Drug X
#>                                        <char>             <char>
#>  1:                                       AGE                   
#>  2:                                         n             333924
#>  3:                                 Mean (SD)        34.5 (7.08)
#>  4:                                    Median               34.0
#>  5:                                  Min, Max             20, 84
#>  6:                                   Missing                  0
#>  7:                                       SEX                   
#>  8:                                         F     173527 (52.0%)
#>  9:                                         M     160397 (48.0%)
#> 10:                                      RACE                   
#> 11:          AMERICAN INDIAN OR ALASKA NATIVE       16823 (5.0%)
#> 12:                                     ASIAN     184009 (55.1%)
#> 13:                 BLACK OR AFRICAN AMERICAN      76493 (22.9%)
#> 14:                                  MULTIPLE        1367 (0.4%)
#> 15: NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER         978 (0.3%)
#> 16:                                     OTHER         615 (0.2%)
#> 17:                                   UNKNOWN         656 (0.2%)
#> 18:                                     WHITE      52983 (15.9%)
#> 19:                                    ETHNIC                   
#> 20:                        HISPANIC OR LATINO      33527 (10.0%)
#> 21:                    NOT HISPANIC OR LATINO     267178 (80.0%)
#> 22:                              NOT REPORTED       19788 (5.9%)
#> 23:                                   UNKNOWN       13431 (4.0%)
#> 24:                                   COUNTRY                   
#> 25:                                       BRA       25981 (7.8%)
#> 26:                                       CAN        4738 (1.4%)
#> 27:                                       CHE         948 (0.3%)
#> 28:                                       CHN     168262 (50.4%)
#> 29:                                       GBR        8567 (2.6%)
#> 30:                                       JPN       15347 (4.6%)
#> 31:                                       NGA       25230 (7.6%)
#> 32:                                       PAK       26117 (7.8%)
#> 33:                                       RUS       17699 (5.3%)
#> 34:                                       USA      41035 (12.3%)
#> 35:                                     DTHFL                   
#> 36:                                         N     278284 (83.3%)
#> 37:                                         Y      55640 (16.7%)
#> 38:                                    BMRKR1                   
#> 39:                                         n             333924
#> 40:                                 Mean (SD) 5.99907 (3.465848)
#> 41:                                    Median            5.34914
#> 42:                                  Min, Max    0.0268, 36.4481
#> 43:                                   Missing                  0
#> 44:                                   REGION1                   
#> 45:                                    Africa       25230 (7.6%)
#> 46:                                      Asia     209726 (62.8%)
#> 47:                                   Eurasia       17699 (5.3%)
#> 48:                                    Europe        8567 (2.6%)
#> 49:                             North America      45773 (13.7%)
#> 50:                             South America       25981 (7.8%)
#> 51:                                    BMRKR2                   
#> 52:                                      HIGH     110964 (33.2%)
#> 53:                                       LOW     111579 (33.4%)
#> 54:                                    MEDIUM     111381 (33.4%)
#>                                         stats          A: Drug X
#>                                        <char>             <char>
#>             B: Placebo     C: Combination
#>                 <char>             <char>
#>  1:                                      
#>  2:             333087             332989
#>  3:        34.5 (7.08)        34.5 (7.09)
#>  4:               34.0               34.0
#>  5:             20, 86             20, 89
#>  6:                  0                  0
#>  7:                                      
#>  8:     173167 (52.0%)     172556 (51.8%)
#>  9:     159920 (48.0%)     160433 (48.2%)
#> 10:                                      
#> 11:       16435 (4.9%)       16551 (5.0%)
#> 12:     183379 (55.1%)     183398 (55.1%)
#> 13:      76700 (23.0%)      76367 (22.9%)
#> 14:        1304 (0.4%)        1294 (0.4%)
#> 15:        1004 (0.3%)        1054 (0.3%)
#> 16:         693 (0.2%)         644 (0.2%)
#> 17:         624 (0.2%)         666 (0.2%)
#> 18:      52948 (15.9%)      53015 (15.9%)
#> 19:                                      
#> 20:       33122 (9.9%)      33604 (10.1%)
#> 21:     266445 (80.0%)     266303 (80.0%)
#> 22:       20149 (6.0%)       19896 (6.0%)
#> 23:       13371 (4.0%)       13186 (4.0%)
#> 24:                                      
#> 25:       25698 (7.7%)       25833 (7.8%)
#> 26:        4783 (1.4%)        4593 (1.4%)
#> 27:         980 (0.3%)         983 (0.3%)
#> 28:     168213 (50.5%)     168093 (50.5%)
#> 29:        8284 (2.5%)        8419 (2.5%)
#> 30:       15475 (4.6%)       15522 (4.7%)
#> 31:       25404 (7.6%)       25438 (7.6%)
#> 32:       26043 (7.8%)       25885 (7.8%)
#> 33:       17587 (5.3%)       17359 (5.2%)
#> 34:      40620 (12.2%)      40864 (12.3%)
#> 35:                                      
#> 36:     277476 (83.3%)     277339 (83.3%)
#> 37:      55611 (16.7%)      55650 (16.7%)
#> 38:                                      
#> 39:             333087             332989
#> 40: 5.98759 (3.463290) 6.01001 (3.475432)
#> 41:            5.33223            5.35129
#> 42:    0.0271, 33.5416    0.0422, 34.2376
#> 43:                  0                  0
#> 44:                                      
#> 45:       25404 (7.6%)       25438 (7.6%)
#> 46:     209731 (63.0%)     209500 (62.9%)
#> 47:       17587 (5.3%)       17359 (5.2%)
#> 48:        8284 (2.5%)        8419 (2.5%)
#> 49:      45403 (13.6%)      45457 (13.7%)
#> 50:       25698 (7.7%)       25833 (7.8%)
#> 51:                                      
#> 52:     111066 (33.3%)     111115 (33.4%)
#> 53:     111021 (33.3%)     110749 (33.3%)
#> 54:     111000 (33.3%)     111125 (33.4%)
#>             B: Placebo     C: Combination
#>                 <char>             <char>
```

## Benchmarking AET01

``` r

arm_var <- "ARM"
aesi_vars <- c(
  "FATAL", "SER", "SERWD", "SERDSM", "RELSER",
  "WD", "DSM", "REL", "RELWD", "RELDSM", "SEV"
)

bench::mark(
  tern_safety_tab <- dtlg::tern_AET01_table(
    adsl = adsl_small,
    adae = aesi,
    patient_var = "USUBJID",
    treat_var = "ARM",
    aesi_vars = aesi_vars
  ),

  dtlg_safety_tab <- dtlg::AET01_table(
    adsl = adsl_small,
    adae = aesi,
    patient_var = "USUBJID",
    treat_var = "ARM",
    aesi_vars = aesi_vars
  ),
  iterations = 1L,
  check = FALSE
)
#> Warning: Some expressions had a GC in every iteration; so filtering is
#> disabled.
#> # A tibble: 2 × 6
#>   expression                             min median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr>                           <bch> <bch:>     <dbl> <bch:byt>    <dbl>
#> 1 tern_safety_tab <- dtlg::tern_AET01… 478ms  478ms      2.09   134.5MB     4.19
#> 2 dtlg_safety_tab <- dtlg::AET01_tabl… 134ms  134ms      7.48    37.5MB     0
```
