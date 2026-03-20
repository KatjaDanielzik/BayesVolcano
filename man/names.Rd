\name{names}
\alias{names}
\docType{data}
\title{
  Metabolite names
}
\description{
  A vector of 98 metabolite names corresponding to the posterior
}
\usage{data("names")}
\format{
  A vector of length 98. 
  of the Bayesian model.
}
\source{
  \bold{Script used to create simulated data}
  
  library(MetaboDynamics)
  data("longitudinalMetabolomics_df")
  names <- levels(as.factor(longitudinalMetabolomics_df$metabolite))
  
}

\keyword{datasets}