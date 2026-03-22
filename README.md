
# BayesVolcano

<!-- badges: start -->
[![R-CMD-check](https://github.com/KatjaDanielzik/BayesVolcano/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/KatjaDanielzik/BayesVolcano/actions/workflows/R-CMD-check.yaml)
[![CRAN status](https://www.r-pkg.org/badges/version/BayesVolcano)](https://CRAN.R-project.org/package=BayesVolcano)
<!-- badges: end -->

# Why a Bayesian Volcano Plot Package?
Bayesian models are used to estimate effect sizes (e.g., gene expression changes,
protein abundance differences, drug response effects) while accounting for uncertainty, 
small sample sizes, and complex experimental designs.
However, Bayesian posteriors of models with many parameters are often difficult
to interpret at a glance.

One way to quickly identify important biological changes based on frequentist analysis 
are volcano plots (using fold-changes and p-values).

Bayesian volcano plots bring together the uncertainty aware power of Bayesian 
models and the familiar visualization of volcano plots by:

   1) Showing posterior medians on the x-axis.
   2) Calculation and using ![equation](https://latex.codecogs.com/svg.image?%5Cpi)-values on the y-axis as a summary 
      of posterior parameter values lying beyond a threshold.
      With *i* being one entity that was modeled and *param* the estimated parameter
![equation](https://latex.codecogs.com/svg.image?%5Cpi_%7Bi%7D=2*max%5Cleft(%5Cint_%7Bparam_%7Bi%7D=-%5Cinfty%7D%5E%7B0%7Dp(param_%7Bi%7D)%5C,d%20param_%7Bi%7D,%5Cint_%7Bparam_%7Bi%7D=0%7D%5E%7B%5Cinfty%7Dp(param_%7Bi%7D)%5C,d%20param_%7Bi%7D%5Cright)-1%20)

   3) Optional displaying credible intervals (CrIs) to visualize uncertainty.
   4) Preserving the familiar, intuitive volcano structure.
   
We are not the first to think about the concept of Bayesian volcano plots [Sousa et al. 2020](https://doi.org/10.1016/j.aca.2019.11.006) introduced them as a single
use case (their b-values correspond to our pi-values)
but to our knowledge we are the first to provide an R-package
for easy calculation of pi-values and visualization. 

## Installation

You can install the development version of BayesVolcano from [GitHub](https://github.com/) with:

``` r
remotes::install_github("KatjaDanielzik/BayesVolcano")
```

and after acceptance to [CRAN](https://cran.r-project.org/) with:

``` r
install.packages("BayesVolcano")
```

## Basic workflow

Input: Posterior of one parameters that should be visualized and an annotation
data frame mapping parameter names to labels and optional additional columns.

``` r
library(BayesVolcano)
data("posterior")
data("annotation_df")

result <- prepare_volcano_df(
   posterior = posterior,
   annotation_df = annotation_df
 )
plot_volcano(result,
             color="group",
             label="label",
             label.pi.threshold = 0.9,
             label.parameter.threshold = 0.5)
```

![](man/figures/README-example_volcano.png)

# References
Julie de Sousa, Ondřej Vencálek, Karel Hron, Jan Václavík, David Friedecký, Tomáš Adam,
Bayesian multiple hypotheses testing in compositional analysis of untargeted metabolomic data,
Analytica Chimica Acta, Volume 1097, 2020, Pages 49-61, ISSN 0003-2670,
https://doi.org/10.1016/j.aca.2019.11.006.
(https://www.sciencedirect.com/science/article/pii/S0003267019313492)

Corresponding GitHub Repository: https://github.com/sousaju/BayesVolcano
