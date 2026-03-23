#' pi_value
#'
#' Calculates pi-value as integral under
#'
#' @param value numerical vector of posterior draws
#' @param zero.effect numerical value indicating for which the central parameter value corresponding to no effect
#'
#' @returns pi-value
#' @keywords internal
.pi_value <- function(value, zero.effect) {
  l <- length(value)
  pi <- 2 * max(sum(value <= zero.effect) / l, sum(value >= zero.effect) / l) - 1
  return(pi)
}

#' CrI width
#'
#' @param CrI.low lower bound of credible interval
#' @param CrI.high upper bound of credible interval
#'
#' @returns absolute distance between CrI and zero effect
#' @keywords internal
.CrI.width <- function(CrI.low, CrI.high) {
  d.CrI <- abs(CrI.high - CrI.low)
}
