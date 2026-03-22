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
library(BayesVolcano)
data("posterior")

annotation_df <- as.data.frame(cbind(parameter=colnames(posterior),
label=levels(as.factor(longitudinalMetabolomics_df$metabolite)),
group=rep(c("A","B")),value=rnorm(98,10,3)))
annotation_df$value <- as.numeric(annotation_df$value)
}

\keyword{datasets}