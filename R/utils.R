#' pi_value
#' 
#' Calculates pi-value as integral under
#'
#' @param value numerical vector of posterior draws
#' @param threshold numerical value indicating for which treshhold to calculate pi
#'
#' @returns pi-value
#' @keywords internal
.pi_value <- function(value, threshold) {
  l <- length(value)
  pi <- 2*max(sum(value<=threshold)/l, sum(value>=threshold)/l)-1
  return(pi)
}