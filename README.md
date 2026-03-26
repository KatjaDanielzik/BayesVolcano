
# BayesVolcano

<!-- badges: start -->
<!-- badges: end -->

# Why a Bayesian Volcano Plot Package?
Bayesian models are essential for studying complex biological systems of interest
(SOIs), such as irradiation effects on metabolite concentrations or vaccine impacts
on immune gene repertoires. In these models layered parameters describe key biological 
features of the SOIs. After model fitting, each parameter is characterized by a 
posterior distribution: a probability distribution representing all plausible 
effect values given the observed data. With thousands of such posteriors in 
high-dimensional analyses, identifying large, reliable effects becomes challenging.

Traditional **volcano plots** address this for frequentist analyses by plotting 
fold-changes against –log(p-values). We introduce **Bayesian volcano plots** 
that instead visualize the posterior mean effect size of parameter $i$ ($\theta_i$) 
against the probability, $\pi_i$, where the $\pi_i$ quantifies the posterior 
probability that $\theta_i$ is not equal the null effect. This directly highlights 
both magnitude and biological relevance. While [Sousa et al. (2020)](https://doi.org/10.1016/j.aca.2019.11.006)
conceptualized Bayesian volcano plots, our R package provides the 
first practical implementation for automated $\pi_i$ calculation and 
visualization of complex biological effects.

With  $\theta_i$ being the effect size of parameter $i$ we calculate calculate
$\pi_i$ as:

$\pi_i = 2 \cdot \max\left(\int_{\theta_i = -\infty}^{\bar{\theta}} p(\theta_i)\mathrm{d}\theta_i, \int_{\theta_i = \bar{\theta}}^{\infty} p(\theta_i)\mathrm{d}\theta_i\right) - 1$

Where $\bar{\theta}$ is the null effect. This measures the probability that the 
effect is in the "direction" away from the null. 

- $\pi \approx 1$: Strong evidence for an effect
- $\pi \approx 0$: Negligible evidence for an effect

**Important Note**: A $\pi$-value near 0 doesn't prove the absence of an effect,
but indicates the posterior is widely distributed around the null.

The figure below shows on the **left the posterior distribution** and 
on the **right the resulting Bayesian volcano plot** where 

- Wide credible intervals = Small points
- Narrow credible intervals = Large points

![](man/figures/README-explain_volcano.png)

## Installation

You can install the development version of BayesVolcano from GitHub with:

``` r
remotes::install_github("KatjaDanielzik/BayesVolcano")
```

and after acceptance to [CRAN](https://cran.r-project.org/) with:

``` r
install.packages("BayesVolcano")
```

## Basic workflow

Input: Posterior of parameters that should be visualized and an annotation
data frame mapping parameter names to labels and optional additional columns.

``` r
library(BayesVolcano)
data("posterior")
data("annotation_df")

result <- prepare_volcano_input(
   posterior = posterior,
   annotation = annotation_df,
   null.effect = 0, # central parameter value corresponding to no effect
   CrI_level = 0.95 # 95% CrI interval
 )
plot_volcano(result,
             CrI_width = FALSE, # optional display of credible intervals as point size
             color="group" # optional color coding)
```

The function plot_volcano() returns a ggplot object that can further be customized by the user.

![](man/figures/README-example_volcano.png)

# References
Julie de Sousa, Ondřej Vencálek, Karel Hron, Jan Václavík, David Friedecký, Tomáš Adam,
Bayesian multiple hypotheses testing in compositional analysis of untargeted metabolomic data,
Analytica Chimica Acta, Volume 1097, 2020, Pages 49-61, ISSN 0003-2670,
https://doi.org/10.1016/j.aca.2019.11.006.
(https://www.sciencedirect.com/science/article/pii/S0003267019313492)

Corresponding GitHub Repository: https://github.com/sousaju/BayesVolcano
