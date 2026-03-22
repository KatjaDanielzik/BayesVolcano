#' pi_value
#' 
#' Calculates pi-value as integral under
#'
#' @param value numerical vector of posterior draws
#' @param zero.effect numerical value indicating for which treshhold to calculate pi
#'
#' @returns pi-value
#' @keywords internal
.pi_value <- function(value, zero.effect) {
  l <- length(value)
  pi <- 2*max(sum(value<=zero.effect)/l, sum(value>=zero.effect)/l)-1
  return(pi)
}