#' Prepare volcano data frame
#'
#' This function has as input posterior draws and annotates them with biological
#' information (e.g., cell line, time point) based on parameter names and a user-provided
#' annotation data frame, calculates pi-values and credible intervals (CrI) and returns a data frame that is ready for plotting.
#'
#' @param posterior A data frame of posterior draws (one row per draw) [extract_stan_fit()].
#' @param n_samples Number of samples from the posterior, default is 1000.
#' @param annotation_df A data frame with at least one column:
#'   \itemize{
#'     \item \code{parameter}: the parameter name (e.g., `doubling.1`, `logOR.treatment`)
#'     \item \code{label}: the biological label (e.g., `cell.line`, `time.point`)
#'     \item Optional: other columns (e.g., `group`, `condition`) for future coloring
#'   }
#' @param threshold For which threshold to calculate pi. Default is 0.   
#' @param CrI.low lower bound of credible interval
#' @param CrI.high upper bound of credible interval
#'
#'
#' @return A list with:
#' \itemize{
#'   \item \code{result}: A data frame with columns:
#'     \itemize{
#'     \item \code{draw}: posterior draw ID (1 to nrow(posterior))
#'     \item \code{sample}: sample ID (1 to n_samples)
#'     \item \code{parameter}: original parameter name
#'     \item \code{value}: posterior draw value
#'     \item \code{label}: biological label (e.g., `cell.line`)
#'     \item Other columns from `annotation_df` (e.g., `group`, `condition`)
#'     \item \code{pi.value}: calulcated pi.value
#'     \item \code{parameter.median}: median posterior parameter value
#'     \item \code{parameter.low}: lower boundary of CrI of parameter value
#'     \item \code{paramter.high}: upper boundary of CrI of parameter value
#'   }
#'   \item \code{meta}: user settings
#' \itemize{
#'   \item \code{CrI.low}: lower CrI boundary set by user
#'   \item \code{CrI.high}: upper CrI boundary set by user
#'   \item \code{threshold}: threshold for pi set by user
#'   }
#'}
#'
#' @seealso [extract_stan_fit()]
#' 
#' @import magrittr
#' @importFrom tidyr pivot_longer
#' @importFrom dplyr left_join
#' @importFrom dplyr arrange
#' @importFrom dplyr mutate
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
#'   n_samples = 100,
#'   annotation_df = annotation_df,
#' )
#' 
#' head(result$result)
#'

prepare_volcano_df <- function(
    posterior,
    n_samples = 1000,
    annotation_df,
    threshold = 0,
    CrI.low = 0.025,
    CrI.high = 0.975
) {
  # Input validation
  if (!is.data.frame(posterior)) {
    stop("Argument 'posterior' must be a data frame.")
  }
  if (n_samples <= 0) {
    stop("Argument 'n_samples' must be positive.")
  }
  if(!is.numeric(threshold)){
    stop("threshold has to be numeric")
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
  draw <- NULL
  
  # Assign draw ID
  posterior$draw <- seq_len(nrow(posterior))
  
  # Sample draw indices
  sample_indices <- sample(nrow(posterior), size = n_samples, replace = TRUE)
  
  # Create sample ID column
  sample_draws <- posterior[sample_indices, ]
  sample_draws$sample <- seq_len(n_samples)
  
  # Convert to long format
  sample_draws_long <- sample_draws %>%
    tidyr::pivot_longer(
      cols = annotation_df$parameter,
      names_to = "parameter",
      values_to = "value"
    )
  
  # Join with annotation_df
  result <- sample_draws_long %>%
    dplyr::left_join(annotation_df, by = "parameter") 
  
  # calculate pi
  result <- result%>%
    dplyr::group_by(parameter)%>%
    dplyr::mutate(pi.value=.pi_value(value = value,threshold = threshold),
                  parameter.median = median(value),
                  parameter.low = quantile(value, CrI.low, na.rm = TRUE),
                  paramter.high = quantile(value, CrI.high, na.rm = TRUE))
  
  # Final cleanup
  result <- result %>%
    dplyr::arrange(sample) %>%
    dplyr::mutate(
      draw = as.integer(draw),
      sample = as.integer(sample),
      value = as.numeric(value)
    )
  
  return(list(result=result,meta=list(CrI.low=CrI.low,CrI.high=CrI.high,threshold=threshold)))
}