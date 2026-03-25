#' Plot Bayesian Volcano plot
#'
#' @param result from [prepare_volcano_input()] (a data frame).
#' @param CrI Logical. Whether to display the CrI Interval of the parameter
#' @param CrI_width Logical. Whether to display the CrI width as point size.
#' @param color Column in `result$result. Can be numerical or character.
#'
#' @returns a ggplot2 object
#'
#' @import ggplot2
#'
#' @export
#'
#' @examples
#' data("posterior")
#' head(posterior)
#' data("annotation_df")
#' head(annotation_df)
#'
#' result <- prepare_volcano_input(
#'   posterior = posterior,
#'   annotation = annotation_df,
#' )
#' plot_volcano(result,
#'   color = "group",
#'   CrI = TRUE,
#'   CrI_width = TRUE
#' )
plot_volcano <- function(result,
                         CrI = FALSE,
                         CrI_width = FALSE,
                         color = NULL) {
  # Input validation
  if (!is.data.frame(result)) {
    stop("'result' must be a data frame.")
  }

  if (!is.logical(c(CrI))) {
    stop("'CrI' must be either 'TRUE' or 'FALSE'")
  }
  if (!is.logical(c(CrI_width))) {
    stop("'CrI_width' must be either 'TRUE' or 'FALSE'")
  }

  # Binding of global variables
  parameter.median <- NULL
  pi.value <- NULL
  null.effect <- NULL
  parameter.low <- NULL
  parameter.high <- NULL
  CrI.level <- NULL
  CrI.width <- NULL

  # create base plot ####
  ## get threshold
  t <- unique(result$null.effect)

  title <- "Bayesian Volcano plot"
  subtitle <- paste0("vertical grey line: zero effect of parameter = ", t)

  p <- ggplot(result, (aes(x = parameter.median, y = pi.value))) +
    geom_point() +
    theme_bw() +
    # mark user set null.effect
    geom_vline(aes(xintercept = t),col="grey") +
    xlab(xlab) +
    ylab(expression(pi)) +
    ggtitle(title, subtitle)
  
  # add errorbar ####
  if (CrI == TRUE) {
    subtitle <- paste0(
      subtitle, "\n",
      "errorbar: ",unique(result$CrI.level)*100," % CrI"
    )
    
    p <- ggplot(result, (aes(x = parameter.median, y = pi.value))) +
      geom_errorbar(aes(xmin = parameter.low, xmax = parameter.high), 
                    col = "grey",
                    width = 0) +
      geom_point() +
      theme_bw() +
      # mark user set null.effect
      geom_vline(aes(xintercept = t),col="grey") +
      xlab(xlab) +
      ylab(expression(pi)) +
      ggtitle(title, subtitle)
  }

  if (CrI_width == TRUE) {
    subtitle <- paste0(
      subtitle, "\n",
      "point size = |CrI|"
    )
    p <- p + 
      geom_point(aes(size = -CrI.width)) +
      ggtitle(title, subtitle)
  }

  # add color ####
  if (!is.null(color)) {
    if (CrI_width == FALSE) {
      if (is.numeric(result[[color]])) {
        temp <- as.symbol(color)
        temp <- enquo(temp)
        p <- p +
          geom_point(aes(col = !!temp)) +
          scale_color_viridis_c()
      }
      if (is.character(result[[color]])) {
        temp <- as.symbol(color)
        temp <- enquo(temp)
        p <- p +
          geom_point(aes(col = !!temp)) +
          scale_color_viridis_d()
      }
    }
    if (CrI_width == TRUE) {
      if (is.numeric(result[[color]])) {
        temp <- as.symbol(color)
        temp <- enquo(temp)
        p <- p +
          geom_point(aes(col = !!temp, size = -CrI.width)) +
          scale_color_viridis_c()
      }
      if (is.character(result[[color]])) {
        temp <- as.symbol(color)
        temp <- enquo(temp)
        p <- p +
          geom_point(aes(col = !!temp, size = -CrI.width)) +
          scale_color_viridis_d()
      }
    }
  }
  return(p)
}
