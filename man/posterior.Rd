\name{posterior}
\alias{posterior}
\docType{data}
\title{
  A posterior with parameter "delta_mu"
}
\description{
  A data frame with 98 columns (each indicating posterior samples of the paramter
  "delta_mu" of one biological entity like e.g.
  a metabolite) and 1000 rows (the number of total samples (chains*iterations))
  of the Bayesian model. 
}
\usage{data("posterior")}
\format{
    A data frame with 98 columns (each indicating posterior samples of the paramter
  "delta_mu" of one biological entity like e.g.
  a metabolite) and 1000 rows (the number of total samples (chains*iterations))
  of the Bayesian model.
}
\source{
 \bold{Script used to create simulated data}
#BiocManager::install("MetaboDynamics") 
library(MetaboDynamics)
data("longitudinalMetabolomics_df")
fit_dynamics_model(data=longitudinalMetabolomics_df)
posterior <- as.data.frame(rstan::extract(fit,pars="euclidean_distance"))

library(stringr)
cols <- colnames(posterior)[str_detect(pattern = ".1.2",string=colnames(posterior))]
posterior <- posterior[,cols]
posterior <- posterior[,-c(1:10,109:118)]

}

\keyword{datasets}
