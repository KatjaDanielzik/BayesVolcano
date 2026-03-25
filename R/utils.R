#' pi_value
#'
#' Calculates pi-value as integral under
#'
#' @param value numerical vector of posterior draws
#' @param null.effect numerical value indicating for which the central parameter value corresponding to no effect
#'
#' @returns pi-value
#' @keywords internal
.pi_value <- function(value, null.effect) {
  l <- length(value)
  pi <- 2 * max(sum(value <= null.effect) / l, sum(value >= null.effect) / l) - 1
  return(pi)
}

6

#' CrI width
#' @param CrI.low lower bound of credible interval
#' @param CrI.high upper bound of credible interval
#' @returns absolute distance lower and upper bound of CrI
#' @keywords internal
.CrI.width <- function(CrI.low, CrI.high) {
  d.CrI <- abs(CrI.high - CrI.low) 
}