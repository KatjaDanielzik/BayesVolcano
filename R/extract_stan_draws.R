#' extract_stan_draws
#'
#' Wrapper function to extract parameter draws from  from common Stan interfaces.
#' This function requires the respective stan interface (rstan, brms, cmdstanr, or rstanarm) 
#'package to be installed.
#' If not available, you'll get an error.
#'
#' @param fit A fitted Stan model object (e.g., `stanfit`, `brmsfit`, `stanreg`, `cmdstanfit`).
#' @param parameter_name A character string of parameter name
#'
#' @returns  A data frame with one row per MCMC draw and one column per parameter.
#'   If multiple parameters, columns are named after the parameter.
#' 
#' @export
#'
#' @examples
#'  #Not run:
#'  #fit <- brms::brm(count ~ zAge + zBase * Trt + (1|patient),
#`  #         data = epilepsy[1:30,], family = poisson())
#' 
#'  # posterior <- extract_stan_draws(fit, "b_Intercept")
#'  # End(Not run)

extract_stan_draws <- function(fit, parameter_name) {
  # rstan
  if (inherits(fit, "stanfit")) {
    if (!requireNamespace("rstan", quietly = TRUE)) {
      stop("Package 'rstan' is required to use this function. Please install it via: ",
           "install.packages('rstan')", call. = FALSE)
    }
    return(as.data.frame(rstan::extract(fit,pars=parameter_name)))
  } 
  # brms
  else if (inherits(fit, "brmsfit")) {
    if (!requireNamespace("brms", quietly = TRUE)) {
      stop("Package 'brms' is required to use this function. Please install it via: ",
           "install.packages('brms')", call. = FALSE)
    }
    return(brms::as_draws_df(fit, variable = parameter_name))
  } 
  # rstanarm
  else if (inherits(fit, "stanreg")) {
    if (!requireNamespace("rstanarm", quietly = TRUE)) {
      stop("Package 'rstanarm' is required to use this function. Please install it via: ",
           "install.packages('rstanarm')", call. = FALSE)
    }
    return(rstanarm::as_draws_df(fit, pars = parameter_name))
  }
  # cmdstanfit
  else if (inherits(fit, "cmdstanfit")) {
    if (!requireNamespace("cmdstanr", quietly = TRUE)) {
      stop("Package 'cmdstanr' is required to use this function. Please install it via: ",
           "install.packages('cmdstanr')", call. = FALSE)
    }
    return(as.data.frame(fit$draws(variables = parameter_name)))
  } 
  else {
    stop("Unsupported model type, please extract posteriors yourself")
  }
}