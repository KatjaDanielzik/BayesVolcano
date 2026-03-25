#' Prepare volcano input
#'
#' This function has as input posterior draws, calculates pi-values and credible intervals (CrI),
#' and annotates them with biological
#' information (e.g., cell line, time point) based on parameter names and a user-provided
#' annotation data frame. Returns a data frame that is ready for plotting.
#'
#' @param posterior A data frame of posterior draws (one row per draw) [extract_fit()].
#' @param annotation A data frame with at least one column:
#'   \itemize{
#'     \item \code{parameter}: the parameter name (e.g., `doubling.1`, `logOR.treatment`)
#'     \item \code{label}: the biological label (e.g., `cell.line`, `time.point`)
#'     \item Optional: other columns (e.g., `group`, `condition`) for future coloring
#'   }
#' @param null.effect Central parameter value corresponding to no effect (default t=0).
#' @param CrI_level  a scalar between 0 and 1 specifying the mass within the credible interval (default=0.95, i.e. 95% credible interval (CrI)).
#'
#' @details
#' Only returns pi-values and credible intervals for parameters that are **in posterior and
#' annotation**. For formula see README or Vignette
#'
#'
#' @return A list with:
#' \itemize{
#'   \item \code{result}: A data frame with columns:
#'     \itemize{
#'     \item \code{parameter}: original parameter name
#'     \item \code{pi.value}: calculated pi.value
#'     \item \code{null.effect}: set null effect by user
#'     \item \code{parameter.median}: median posterior parameter value
#'     \item \code{parameter.low}: lower boundary of CrI of parameter value
#'     \item \code{paramter.high}: upper boundary of CrI of parameter value
#'     \item \code{CrI.width}: the absolute distance between parameter.low and parameter.high
#'     \item \code{CrI.level}: CrI_level set by user
#'     \item \code{label}: biological label (e.g., `cell.line`)
#'     \item Other columns from `annotation` (e.g., `group`, `condition`)
#'   }
#' }
#'
#' @seealso [extract_fit()]
#'
#' @import magrittr
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr left_join
#' @importFrom purrr list_rbind
#' @importFrom stats median
#' @importFrom HDInterval hdi
#'
#'
#' @export
#'
#' @examples
#' # Example: Simulate posterior and annotation
#' posterior <- data.frame(
#'   doubling.1 = rnorm(1000),
#'   doubling.2 = rnorm(1000)
#' )
#'
#' annotation <- data.frame(
#'   parameter = c("doubling.1", "doubling.2"),
#'   label = c("cell.line.A", "cell.line.B"),
#'   group = c("group1", "group1")
#' )
#'
#' result <- prepare_volcano_input(
#'   posterior = posterior,
#'   annotation = annotation,
#' )
#'
#' head(result$result)
#'
prepare_volcano_input <- function(
  posterior,
  annotation,
  null.effect = 0,
  CrI_level = 0.95
) {
  # Input validation
  if (!is.data.frame(posterior)) {
    stop("Argument 'posterior' must be a data frame.")
  }
  if (!is.numeric(null.effect)) {
    stop("null.effect must be numeric")
  }
  if (!is.numeric(c(CrI_level))|!(CrI_level>=0&CrI_level<=1)) {
    stop("CrI_level must be numeric and in between 0 and 1")
  }
  if (!is.data.frame(annotation)) {
    stop("Argument 'annotation' must be a data frame.")
  }
  if (!"parameter" %in% names(annotation)) {
    stop("annotation must contain a column 'paramter'")
  }
  if (!"label" %in% names(annotation)) {
    stop("annotation must contain a column 'label'")
  }

  # Binding of global variables
  parameter <- NULL
  value <- NULL


  # Compute summaries per parameter using lapply
  summaries <- lapply(annotation$parameter, function(param) {
    if (!param %in% names(posterior)) {
      return(NULL)
    }
    values <- posterior[[param]]

    # Compute stats
    pi_value <- .pi_value(
      value = values,
      null.effect = null.effect
    )
    median_val <- median(values)
    crI_low <- as.numeric(HDInterval::hdi(values,credMass = CrI_level)["lower"])
    crI_high <- as.numeric(HDInterval::hdi(values,credMass = CrI_level)["upper"])

    # Return as data frame

    return(as.data.frame(cbind(
      parameter = param,
      pi.value = pi_value,
      null.effect = null.effect,
      parameter.median = median_val,
      parameter.low = crI_low,
      parameter.high = crI_high,
      CrI.width = .CrI.width(CrI.low = crI_low, CrI.high = crI_high),
      CrI.level = CrI_level
    )))
  })

  summaries <- purrr::list_rbind(summaries)
  rownames(summaries) <- NULL

  # Join with annotation
  result <- summaries %>%
    dplyr::left_join(annotation, by = "parameter")

  # clean up
  result$pi.value <- as.numeric(result$pi.value)
  result$null.effect <- as.numeric(result$null.effect)
  result$parameter.median <- as.numeric(result$parameter.median)
  result$parameter.low <- as.numeric(result$parameter.low)
  result$parameter.high <- as.numeric(result$parameter.high)
  result$CrI.width <- as.numeric(result$CrI.width)
  result$CrI.level <- as.numeric(result$CrI.level)

  return(result)
}
