#' Prepare volcano data frame
#'
#' This function has as input posterior draws, calculates pi-values and credible intervals (CrI),
#' and annotates them with biological
#' information (e.g., cell line, time point) based on parameter names and a user-provided
#' annotation data frame. Returns a data frame that is ready for plotting.
#'
#' @param posterior A data frame of posterior draws (one row per draw) [extract_fit()].
#' @param annotation_df A data frame with at least one column:
#'   \itemize{
#'     \item \code{parameter}: the parameter name (e.g., `doubling.1`, `logOR.treatment`)
#'     \item \code{label}: the biological label (e.g., `cell.line`, `time.point`)
#'     \item Optional: other columns (e.g., `group`, `condition`) for future coloring
#'   }
#' @param zero.effect Central parameter value corresponding to no effect (default t=0).
#' @param CrI.low lower bound of credible interval
#' @param CrI.high upper bound of credible interval
#'
#' @details
#' Only returns pi-values and credible intervals for parameters that are **in posterior and
#' annotation_df**. For formula see README or Vignette
#'
#'
#' @return A list with:
#' \itemize{
#'   \item \code{result}: A data frame with columns:
#'     \itemize{
#'     \item \code{parameter}: original parameter name
#'     \item \code{pi.value}: calculated pi.value
#'     \item \code{parameter.median}: median posterior parameter value
#'     \item \code{parameter.low}: lower boundary of CrI of parameter value
#'     \item \code{paramter.high}: upper boundary of CrI of parameter value
#'     \item \code{CrI.width}: the absolute distance parameter.low and parameter.high
#'     \item \code{label}: biological label (e.g., `cell.line`)
#'     \item Other columns from `annotation_df` (e.g., `group`, `condition`)
#'   }
#'   \item \code{meta}: user settings
#' \itemize{
#'   \item \code{CrI.low}: lower CrI boundary set by user
#'   \item \code{CrI.high}: upper CrI boundary set by user
#'   \item \code{zero.effect}: zero.effect for pi set by user
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
#' @importFrom stats quantile
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
#' annotation_df <- data.frame(
#'   parameter = c("doubling.1", "doubling.2"),
#'   label = c("cell.line.A", "cell.line.B"),
#'   group = c("group1", "group1")
#' )
#'
#' result <- prepare_volcano_df(
#'   posterior = posterior,
#'   annotation_df = annotation_df,
#' )
#'
#' head(result$result)
#'
prepare_volcano_df <- function(
  posterior,
  annotation_df,
  zero.effect = 0,
  CrI.low = 0.025,
  CrI.high = 0.975
) {
  # Input validation
  if (!is.data.frame(posterior)) {
    stop("Argument 'posterior' must be a data frame.")
  }
  if (!is.numeric(zero.effect)) {
    stop("zero.effect has to be numeric")
  }
  if (any(!is.numeric(c(CrI.low, CrI.high)))) {
    stop("CrI.low and CrI.high must be numeric.")
  }
  if (CrI.low < 0 || CrI.high > 1 || CrI.low >= CrI.high) {
    stop("CrI.low and CrI.high must be between 0 and 1, and CrI.low < CrI.high.")
  }
  if (!is.data.frame(annotation_df)) {
    stop("Argument 'annotation_df' must be a data frame.")
  }
  if (!"parameter" %in% names(annotation_df)) {
    stop("annotation_df has to contain a column 'paramter'")
  }
  if (!"label" %in% names(annotation_df)) {
    stop("annotation_df has to contain a column 'label'")
  }

  # Binding of global variables
  parameter <- NULL
  value <- NULL


  # Compute summaries per parameter using lapply
  summaries <- lapply(annotation_df$parameter, function(param) {
    if (!param %in% names(posterior)) {
      return(NULL)
    }
    values <- posterior[[param]]

    # Compute stats
    pi_value <- .pi_value(
      value = values,
      zero.effect = zero.effect
    )
    median_val <- median(values)
    crI_low <- stats::quantile(values, probs = CrI.low, na.rm = TRUE)
    crI_high <- stats::quantile(values, probs = CrI.high, na.rm = TRUE)
    CrI_width <- .CrI.width(CrI.low = crI_low, CrI.high = crI_high)

    # Return as data frame

    return(as.data.frame(cbind(
      parameter = param,
      pi.value = pi_value,
      parameter.median = median_val,
      parameter.low = crI_low,
      parameter.high = crI_high,
      CrI.width = CrI_width
    )))
  })

  summaries <- purrr::list_rbind(summaries)
  rownames(summaries) <- NULL

  # Join with annotation_df
  result <- summaries %>%
    dplyr::left_join(annotation_df, by = "parameter")

  # clean up
  result$pi.value <- as.numeric(result$pi.value)
  result$parameter.median <- as.numeric(result$parameter.median)
  result$parameter.low <- as.numeric(result$parameter.low)
  result$parameter.high <- as.numeric(result$parameter.high)
  result$CrI.width <- as.numeric(result$CrI.width)

  return(list(result = result, meta = list(
    CrI.low = as.numeric(CrI.low),
    CrI.high = as.numeric(CrI.high),
    zero.effect = as.numeric(zero.effect)
  )))
}
