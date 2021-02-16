
# WBdif

Development of **WBdif** was motivated by questions regarding the
psychometric properties of early childhood development assessments used
as outcome measures in impact evaluations. This package provides methods
for (a) evaluating differential item functioning (DIF), (b) checking
whether DIF leads to biased treatement effects on the unweighted total
score or IRT-based scoring methods, and (c) providing DIF-corrected
treatment effects by either removing biased items (for the unweighted
total score) or using an IRT models that adjusts for the item bias (for
IRT-based scoring). The methods are documented in the report:
(forthcoming).

The methods for evaluating DIF include semi-parametric regression, the
Mantel-Haenszel test, logistic regression, and multi-group item response
theory (IRT).

DIF may be evaluated with respect to the treatment variable, or with
respect to pre-treatment variables used to examine treatment
hetergeneity (e.g., gender, age, and socio-economic status). The
**WBdif** documentation refer to these as unconditional and conditional
treatment effects, respectively.

If assessment items have DIF with respect to treatment, the
unconditional treatment effect *may* be biased. The intuitive
interpretation here is that the treatment effect varies over the
assessment items, so reporting the treatment effect on an aggregate
score (e.g., the unweighted total score) may not reflect “true” effect
on the construct of interest.

If the assessment items have DIF with respect to a conditiong variable
(e.g., gender), the corresponding conditional treatement effects (e.g.,
the effect just for males, just for females, or their difference) *may*
be biased. In other words, randomization of treatement does not protect
conditional treatment effects from DIF with respect to the conditionin
variable.

**WBdif** provides two general workflows, both of which are illustrated
below. In the “basic” workflow, the user preps the data and then calls
an omnibus function (`summary_report`) that automates the DIF analysis
and, if there is any DIF detected, the evaluation of treatment effects.
The results are summarized in an .HTML formatted report.

In the “advanced” workflow, all the steps automated by `summary_report`
can be implemented directly by the user, which gives more control over
which DIF analyses are conducted and which items are identified as
biased. The advanced workflow is currently under construction, as the
output returned by most functions is not very user-friendly. In the
future, these outputs may be converted to S3 or S4 objects with methods
(e.g., print, summary) that make them more user-friendly.

**WBdif** is in the alpha stage of development. Please report any bugs
by opening an issue at (<https://github.com/knickodem/WBdif>).

## Installation

``` r
install.packages("remotes")
remotes::install_github("knickodem/WBdif")
library(WBdif)
```

## Features

Say you have a measure with both dichotomous and polytomous items and
you want to know:

1.  Do any items show DIF by gender?
2.  What method should I use to detect DIF?
3.  What is the treatment effect of the intervention?
4.  Does the treatment effect change when accounting for biased (DIF-y)
    items?

**WBdif** has functionality to accommodate two approaches to answering
these questions depending on your motivations and the nature of the
measure (assessment/instrument/test).

### All-in-One

The first approach requires only two functions (`dif_data_prep()` and
`summary_report()`) and produces an HTML report summarizing the DIF
analysis results from up to 4 methods along with tables and plots
illustrating treatment effects with and without adjusting for item bias.

`dif_data_prep()` is a pre-processing step that organizes input
information for use in other **WBdif** functions and conducts some
checks on the suitability of the data for a DIF analysis. When
investigating treatment effect robustness, `dif_data_prep()` is also
where you specify:

  - whether the treatment effects are unconditional (i.e., only
    comparing treatment group to control group) or conditional on
    another variable (e.g., gender, race, age)
  - which standard deviation to use in the denominator of the treatment
    effect size estimation (`std.group`)
  - whether the data is clustered

`summary_report()` is then a wrapper around all of the other functions
needed to run the analysis and produce the report (hence All-in-One).
Nonetheless, the function offers a variety of options to customize the
both the analysis and reporting. For more details on each option see the
[Step-by-Step](#sbs) section. Given the All-in-One nature of
`summary_report()`, the code may take a few minutes to run before
producing the report.

**Conditional Treatment Effects**

Below we specify both `tx.group.id` and `dif.group.id` indicating that
we are interested in estimating the treatment effects conditional on
gender. The code below generates [this
report](https://htmlpreview.github.io/?https://github.com/knickodem/WBdif/blob/master/DIF-Effects-Gender-MDAT-Language.html).

``` r
data("mdatlang")

conditional <- dif_data_prep(item.data = mdatlang[5:ncol(mdatlang)],
                         tx.group.id = mdatlang$treated,
                         dif.group.id = mdatlang$gender,
                         cluster.id = mdatlang$clusterid,
                         std.group = NULL, # When NULL, the pooled standard deviation is used
                         na.to.0 = TRUE)

summary_report(dif.data = conditional,
             report.type = "dif.effects",
             report.title = "Gender DIF Effects on MDAT Language",
             measure.name = "MDAT Language",
             file.name = "DIF-Effects-Gender-MDAT-Language",
             dataset.name = "Malawi",
             methods = c("loess", "MH", "logistic", "IRT"),
             bias.method = "IRT",
             match.type  = "Total")
```

**Unconditional Treatment Effects**

When interested in unconditional effects, only one of `tx.group.id` or
`dif.group.id` need to be supplied in `dif_data_prep()`.
`summary_report()` recognizes how the data are prepared and estimates
the appropriate treatment effect. Thus, from an analysis standpoint,
`dif.data` is the only argument that needs to be changed in
`summary_report()`. Naturally, adjusting `report.title` helps clarify
which analysis was conducted and and revising `file.name` prevents your
previous reports from being overwritten. The code below generates [this
report](https://htmlpreview.github.io/?https://github.com/knickodem/WBdif/blob/master/DIF-Effects-Tx-MDAT-Language.html).

``` r
data("mdatlang")

unconditional <- dif_data_prep(item.data = mdatlang[5:ncol(mdatlang)],
                         tx.group.id = mdatlang$treated,
                         dif.group.id = NULL,
                         cluster.id = mdatlang$clusterid,
                         std.group = "Control", # "Control" is a value in mdatlang$treated
                         na.to.0 = TRUE)

summary_report(dif.data = unconditional,
             report.type = "dif.effects",
             report.title = "Tx DIF Effects on MDAT Language",
             measure.name = "MDAT Language",
             file.name = "DIF-Effects-Tx-MDAT-Language",
             dataset.name = "Malawi",
             methods = c("loess", "MH", "logistic", "IRT"),
             bias.method = "IRT",
             match.type  = "Total")
```

### Step-by-Step

If want to examine the components contributing to `summary_report()`,
you can conduct the analysis and reporting one step at a time. The first
recommended step is still `dif_data_prep()`, which operates in the same
manner as the [All-in-One](#aio) approach. Once again we have specified
both `tx.group.id` and `dif.group.id` to indicate we are interested in
DIF by Gender and the conditional treatment effects.

``` r
library(WBdif)
data("mdatlang")
prepped <- dif_data_prep(item.data = mdatlang[5:ncol(mdatlang)],
                         tx.group.id = mdatlang$treated,
                         dif.group.id = mdatlang$gender,
                         cluster.id = mdatlang$clusterid,
                         std.group = NULL, # When NULL, the pooled standard deviation is used
                         na.to.0 = TRUE)
```

**DIF Analysis**

The next step is typically `dif_analysis()`, which evaluates DIF by the
two groups in `dif.group.id` with up to 4 DIF methods:

  - LOESS regression - Generates plot of response curves for the two
    groups on each item. DIF is determined through visual inspection of
    differences in the groups’ response curves.
  - Mantel-Haenszel (MH) Test - *only available for dichotomous items* -
    In a two-stage (Initial detection and Refinement stages) process,
    identifies biased items by conducting a Mantel-Haenszel test via
    `stats::mantelhaen.test()` for each item grouped by `dif.group.id`
    and stratified by raw total score (`match.type = "Total"`) or raw
    score removing the item under investigation (`match.type = "Rest"`).
  - Logistic regression - *only available for dichotomous items* - First
    conducts an omnibus test of DIF by comparing fit of no DIF, uniform
    DIF, and non-uniform DIF logistic regression models. If the model
    comparisons suggest DIF, biased items are identified by fitting a
    separate logistic regression model on each item during an initial
    detection stage and refinement stage.
  - Item Response Theory (IRT) - First conducts an omnibus test of DIF
    by comparing the fit of no DIF, uniform DIF, and non-uniform DIF 2PL
    IRT models via `mirt::multiGroup()`. If the model comparisons
    suggest DIF, biased items are identified by iteratively freeing
    parameters and testing model fit using `mirt::DIF()`.

Each method has its own function (`dif_loess()`, `dif_mh()`,
`dif_logistic()`, and `dif_irt()`), which is called by `dif_analysis()`.
One common issue in the MH method is low response rates for a certain
group on a particular item at a given score. A common remedy is bin the
scores, such as by deciles, as shown in the code below.

``` r
dif.analysis <- dif_analysis(dif.data = prepped,
                            methods =  c("loess", "MH", "logistic", "IRT"),
                            match.type = "Rest",
                            match.bins = seq(0, 1, by = .1))
```

If you only want a report of the DIF analysis and the treatment effect
estimates are not of interest, a report including only the DIF results
can be generated by setting `report.type = "dif.only"` in the
`dif_report()` function. The report enables comparison of the DIF
methods with one method highlighted via the `bias.method` argument
([example
report](https://htmlpreview.github.io/?https://github.com/knickodem/WBdif/blob/master/DIF-Only-Gender-MDAT-Language.html)).

``` r
dif_report(dif.analysis = dif.analysis,
           report.type = "dif.only",
           report.title = "Gender DIF in MDAT Language",
           measure.name = "MDAT Language",
           file.name = "DIF-Only-Gender-MDAT-Language",
           dataset.name = "Malawi",
           bias.method = "IRT")
```

**Treatment Effect Estimation**

`effect_robustness()` estimates treatment effects using both a raw total
score approach and an IRT model-based scoring approach. To do so,
`dif_models()` is run first to gather and estimate the necessary IRT
models. Typically, the inputs to `dif_models()` are the output from
`dif_analysis()` and from which DIF method (“logistic”, “MH”, or “IRT”)
to extract the identified biased items. However, if you are interested
in testing the impact of particular items, you can specify in
`biased.items` a vector of the column indices in the data for the items
you want to check along with `dif_data_prep()` object to `dif.data`.

The output from `dif_models()` is then used in `effect_robustness()` to
estimate the treatment effects and their robustness in the presence of
biased items. Which effects and how they are estimated is largely
dictated by the information supplied to `dif_data_prep()`, which is
passed to `effect_robustness()` from `dif_models()`. This includes:

  - unconditional or conditional treatment effects
  - the standard deviation used to standardize the effect size
  - whether the effect sizes and their standard errors are adjusted for
    the clustering of
observations

<!-- end list -->

``` r
    dif.models <- dif_models(dif.analysis = dif.analysis, dif.data = NULL, biased.items = "logistic")
    effect.robustness <- effect_robustness(dif.models = dif.models, std.group = prepped$std.group, irt.scoring = "WLE")
```

A report with just the robustness of treatment effect estimates to
biased items, but no DIF analysis information, can be requested from
`dif_report()` by setting `report.type = "effects.only"` and providing
objects returned from `dif_models()` and `effect_robustness()`. More
often, the DIF analysis results are also of interest, in which case
`report.type = "dif.effects"` and the `dif_analysis()` object must be
supplied. The format and data for the [report generated
here](https://htmlpreview.github.io/?https://github.com/knickodem/WBdif/blob/master/Logistic-Gender-MDAT-Language.html)
is the same as the Conditional Treatment Effects report in the
[All-in-One](#aio) section, but the DIF methods used are different
(logistic vs. IRT; rest scores vs total scores). Comparing the reports
gives an indication of the impact of analysis decisions on conclusions
regarding treatment effects.

``` r
dif_report(dif.analysis = dif.analysis,
           dif.models = dif.models,
           effect.robustness = effect.robustness,
           report.type = "dif.effects",
           report.title = "Gender DIF in MDAT Language",
           measure.name = "MDAT Language",
           file.name = "Logistic-Gender-MDAT-Language",
           dataset.name = "Malawi",
           bias.method = "logistic")
```

## Support and Suggestions

If you encounter any issues or have a suggestion for additional
features, please file a [Github
issue](https://github.com/knickodem/WBdif/issues) or contact us via
email.
