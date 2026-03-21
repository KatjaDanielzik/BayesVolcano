\name{annotation_df}
\alias{annotation_df}
\docType{data}
\title{
  A posterior with parameter "delta_mu"
}
\description{
  A data with two columns "parameter" and "label" corresponding to data("posterior")
}
\usage{data("posterior")}
\format{
    "Parameter" refers to column names of posterior
    "Lable" are the biological entities corresponding to the parameters 
}
\source{
 \bold{Script used to create simulated data}
#BiocManager::install("MetaboDynamics") 
library(MetaboDynamics)
data("longitudinalMetabolomics_df")
fit_dynamics_model(data=longitudinalMetabolomics_df)
posterior <- as.data.frame(rstan::extract(fit,pars="euclidean_distance"))

annotation_df <- as.data.frame(cbind(parameter=colnames(posterior),label=levels(as.factor(longitudinalMetabolomics_df$metabolite))))
}

\keyword{datasets}