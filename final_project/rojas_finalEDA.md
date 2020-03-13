Final Paper Exploratory Data Analysis
================
Alfredo Rojas
3/10/2020

## Final Project for PLAN 672: Initial Summary

This project will explore the relationship between food insecurity
indicators in West Africa and relevant environmental and
household-related variables. This preliminary paper will rely on DHS
survey data. For this specific analysis, the survey data is restricted
to 2011 since the DHS standardizes all their variables across survey
years, i.e. the variables all have the similar code names for easy
comparison.

At the outset, vaiables related to food security, according to Gubert,
et al. (2010) are: per capital income, years of schooling, race and
gender of HH head, urban/rural residence, access to public water supply,
presence of children, total number of household inhabitants, and state
of residence.

This particular project will begin exploring some of these variables
within the DHS data. Later, I will try to incorporte othr related
variables, such as land-use/land-cover change, NDVI, and/or climate
data. As I explore the literature in more detail, I will determine what
will be a feasible route to take for this final project.

Let’s explore some of the variables in the data and see what may be of
interest. Later, I will bring up what variables are commonly used in the
literature and whether they are present in this particular dataset. The
first thing I wanted to look for were differences between rural and
urban households. This distinction will be important to see what kinds
of variables impact food security indicators. For example, does living
in rural or urban settings impact food security measures? If so, to what
extent? These are some of the questions I begin asking as I explore the
DHS data to see what variables I’m able to work with.

The `haven` package allows R to read and interpret data stored in .DTA
format. In this format, categorical variables are stored as
`haven_labelled` class, meaning the categorical variables used in
observations correspond to label names. You can insert these label names
using the `haven::as_factor()` function, as seen in the `ggplot` code
chunk.

``` r
path_name = file.path("CI_Data", "CI_2011-12_DHS_12102019_1545_134297", "CIHR62DT", "")

library(haven)
library(tidyverse)
```

``` r
# Read in Household-level data.
hhci = read_dta(paste0(path_name, "CIHR62FL.DTA"))
head(hhci)
```

    ## # A tibble: 6 x 3,900
    ##   hhid   hv000 hv001 hv002 hv003 hv004  hv005 hv006 hv007 hv008 hv009 hv010
    ##   <chr>  <chr> <dbl> <dbl> <dbl> <dbl>  <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
    ## 1 "    … CI6       1     1     1     1 1.82e6     5  2012  1349     4     1
    ## 2 "    … CI6       1     6     3     1 1.82e6     1  2012  1345     9     1
    ## 3 "    … CI6       1     7     2     1 1.82e6     1  2012  1345     7     1
    ## 4 "    … CI6       1    10     1     1 1.82e6     1  2012  1345     2     1
    ## 5 "    … CI6       1    11     2     1 1.82e6     1  2012  1345     2     0
    ## 6 "    … CI6       1    12     1     1 1.82e6     1  2012  1345     7     0
    ## # … with 3,888 more variables: hv011 <dbl>, hv012 <dbl>, hv013 <dbl>,
    ## #   hv014 <dbl>, hv015 <dbl+lbl>, hv016 <dbl>, hv017 <dbl>, hv018 <dbl>,
    ## #   hv019 <dbl>, hv020 <dbl+lbl>, hv021 <dbl>, hv022 <dbl+lbl>,
    ## #   hv023 <dbl+lbl>, hv024 <dbl+lbl>, hv025 <dbl+lbl>, hv026 <dbl+lbl>,
    ## #   hv027 <dbl+lbl>, hv028 <dbl>, hv030 <dbl>, hv031 <dbl>, hv032 <dbl>,
    ## #   hv035 <dbl>, hv040 <dbl>, hv041 <dbl>, hv042 <dbl+lbl>,
    ## #   hv044 <dbl+lbl>, hv201 <dbl+lbl>, hv202 <dbl+lbl>, hv204 <dbl+lbl>,
    ## #   hv205 <dbl+lbl>, hv206 <dbl+lbl>, hv207 <dbl+lbl>, hv208 <dbl+lbl>,
    ## #   hv209 <dbl+lbl>, hv210 <dbl+lbl>, hv211 <dbl+lbl>, hv212 <dbl+lbl>,
    ## #   hv213 <dbl+lbl>, hv214 <dbl+lbl>, hv215 <dbl+lbl>, hv216 <dbl>,
    ## #   hv217 <dbl+lbl>, hv218 <dbl>, hv219 <dbl+lbl>, hv220 <dbl+lbl>,
    ## #   hv221 <dbl+lbl>, hv225 <dbl+lbl>, hv226 <dbl+lbl>, hv227 <dbl+lbl>,
    ## #   hv228 <dbl+lbl>, hv230a <dbl+lbl>, hv230b <dbl+lbl>, hv232 <dbl+lbl>,
    ## #   hv232b <dbl+lbl>, hv232c <dbl+lbl>, hv232d <dbl+lbl>,
    ## #   hv232e <dbl+lbl>, hv232y <dbl+lbl>, hv234 <dbl+lbl>, hv234a <dbl+lbl>,
    ## #   hv235 <dbl+lbl>, hv236 <dbl+lbl>, hv237 <dbl+lbl>, hv237a <dbl+lbl>,
    ## #   hv237b <dbl+lbl>, hv237c <dbl+lbl>, hv237d <dbl+lbl>,
    ## #   hv237e <dbl+lbl>, hv237f <dbl+lbl>, hv237g <dbl+lbl>,
    ## #   hv237h <dbl+lbl>, hv237i <dbl+lbl>, hv237j <dbl+lbl>,
    ## #   hv237k <dbl+lbl>, hv237x <dbl+lbl>, hv237z <dbl+lbl>, hv238 <dbl+lbl>,
    ## #   hv239 <dbl+lbl>, hv240 <dbl+lbl>, hv241 <dbl+lbl>, hv242 <dbl+lbl>,
    ## #   hv243a <dbl+lbl>, hv243b <dbl+lbl>, hv243c <dbl+lbl>,
    ## #   hv243d <dbl+lbl>, hv244 <dbl+lbl>, hv245 <dbl+lbl>, hv246 <dbl+lbl>,
    ## #   hv246a <dbl+lbl>, hv246b <dbl+lbl>, hv246c <dbl+lbl>,
    ## #   hv246d <dbl+lbl>, hv246e <dbl+lbl>, hv246f <dbl+lbl>,
    ## #   hv246g <dbl+lbl>, hv246h <dbl+lbl>, hv246i <dbl+lbl>,
    ## #   hv246j <dbl+lbl>, hv246k <dbl+lbl>, hv247 <dbl+lbl>, …

``` r
# number of cases
NROW(hhci)
```

    ## [1] 9686

I am going to create a subset data frame to explore some immediate
variables of interest. Note the use of `as_factor()` in the `ggplot()`
function.

``` r
# view average field size, hv012 (# of hh members), hv025 (urban or rural?), hv244 (has ag land), hv245 (ag land in ha)
subset_hh = hhci %>%
  select(hhid, hv012, hv025, hv244, hv245, hv270) %>%
  rename("num_hh_mem" = hv012, "urban_rural" = hv025, "owns_land" = hv244, "ag_area" = hv245, "wealth_index" = hv270)

# compare urban/rural numbers, 1 = urbn, 2 = rural
subset_hh %>%
  group_by(urban_rural) %>%
  summarise(n = n()) %>%
  ggplot(aes(x = as_factor(urban_rural), y = n)) + # as_factor a `haven` function, uses labels for categorical responses
  geom_bar(stat = "identity")
```

![](rojas_finalEDA_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

``` r
# ggsave("rural_urban_bar.png", dpi = 300)
```

I can start looking at the distribution of certain variables of
interest. Let me start with number of household members per each
household observed.

``` r
d = subset_hh$num_hh_mem %>%
  density()

plot(d)
```

![](rojas_finalEDA_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

Now, I’ll look at agricultural area in hectares for each household that
has a farm.

``` r
d2 = subset_hh %>%
  filter(is.na(ag_area) != TRUE) %>%
  select(ag_area)

density(d2$ag_area) %>%
  plot()
```

![](rojas_finalEDA_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

``` r
# ggsave("ag_density.png", dpi = 300)
```

Also, I can look at the relationship between the two variables.

``` r
# plot houehold member number by agri area
subset_hh %>%
  ggplot(aes(x = num_hh_mem, y = ag_area)) +
  geom_point() +
  geom_smooth(method = "loess")
```

![](rojas_finalEDA_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->

``` r
# ggsave("ag_hh_compare.png", dpi = 300)
```

The DHS has another variable that may be of interest: Wealth Index. This
index apparently measures the relative wealth of households and
categorizes them into quintiles.

``` r
# plot wealth vs. agricultural area
subset_hh %>%
  ggplot(aes(x = wealth_index, y = ag_area)) +
  geom_col(aes(fill = as_factor(wealth_index)))
```

![](rojas_finalEDA_files/figure-gfm/unnamed-chunk-7-1.png)<!-- -->

``` r
# ggsave("ag_wealth.png", dpi = 300)
```

One thing that may be of interest is looking at the distribution of
agricultural area by wealth category to see variation within a variable.
The spread of the data is interesting. The different catgories seem to
follow a similar pattern but in different magnitudes.

``` r
# compare distribution of agricultural area across wealth indices
subset_hh %>%
  ggplot(aes(x = ag_area, colour = as_factor(wealth_index))) +
  geom_freqpoly(binwidth = 50)
```

![](rojas_finalEDA_files/figure-gfm/unnamed-chunk-8-1.png)<!-- -->

``` r
# ggsave("ag_wealth_density.png", dpi = 300)
```

From this analysis, I will rely on the availale DHS data variables to
understnd their impact on food security. Food security indicators will
be chosen in the days to come. One indicator may include child stunting,
nutrition, or maternal health variables. In the days to come, I will
update this RMarkdown with more exploratory data analysis (EDA).
