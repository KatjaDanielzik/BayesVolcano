
# BayesVolcano

<!-- badges: start -->
<!-- badges: end -->

# Why a Bayesian Volcano Plot Package?
Bayesian models are used to estimate effect sizes (e.g., gene expression changes,
protein abundance differences, drug response effects) while accounting for uncertainty, 
small sample sizes, and complex experimental designs.
However, Bayesian outputs are often difficult to interpret at a glance.

One way to quickly identify important biological changes of frequentist analysis 
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

## Installation

You can install the development version of BayesVolcano from [GitHub](https://github.com/) with:

``` r
remotes::install_github("KatjaDanielzik/BayesVolcano")
```

## Basic workflow

Input: Posterior of one parameters that should be visualized and an annotation
data frame mapping parameter names to labels and optional additional columns.

``` r
library(BayesVolcano)
data("posterior")
head(posterior)
data("annotation_df")
head(annotation_df)

result <- prepare_volcano_df(
   posterior = posterior,
   annotation_df = annotation_df,
 )
plot_volcano(result,
             color="group",
             label="label",
             label.pi.threshold = 0.9,
             label.parameter.threshold = 0.5)
```

![](man/figures/README-example_volcano.png)