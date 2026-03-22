#' Plot Bayesian Volcano plot
#'
#' @param result from [prepare_volcano_df()] (a list with `result` and `meta`).
#' @param CrI Logical. Whether to display the CrI Interval of the parameter
#' @param color Column in `result$result. Can be numerical or character.
#' @param label Character column name in `result$result` to use for labeling 
#' points (e.g., "label", "parameter").
#' If `NULL`, no labels are shown.
#' @param label.parameter.threshold Numeric vector of length 1, absolute lower bound for label
#' If `NULL` or missing, all points are considered for labeling.
#' @param label.pi.threshold numeric vector of length 1, absolute lower bound for label
#' If `NULL` or missing, all points are considered for labeling.
#' for y-axis to trigger labeling.
#' If `NULL` or missing, all points are considered for labeling.
#' @param title Character. Title of plot
#' @param xlab Character. x-axis label of plot
#'
#' @returns a ggplot2 object
#' 
#' @import ggplot2
#' @import ggrepel
#' 
#' @export
#'
#' @examples 
#' data("posterior")
#' head(posterior)
#' data("annotation_df")
#' head(annotation_df)
#'  
#' result <- prepare_volcano_df(
#'   posterior = posterior,
#'   annotation_df = annotation_df,
#' )
#' plot_volcano(result,
#'             color="group",
#'             label="label",
#'             label.pi.threshold = 0.9,
#'             label.parameter.threshold = 0.5)

plot_volcano <- function(result,
                         CrI = FALSE,
                         color = NULL,
                         label = NULL,
                         label.parameter.threshold = NULL,
                         label.pi.threshold = NULL,
                         title = "Bayesian Volcano Plot",
                         xlab = "median parameter value"){

  # Input validation
  if (!is.list(result) || !("result" %in% names(result)) || !("meta" %in% names(result))) {
    stop("Argument 'result' must be a list with 'result' and 'meta' components from prepare_volcano_df().")
  }
  
  df <- result$result
  
  # Check if label column exists
  if (!is.null(label) && !(label %in% names(df))) {
    stop("Label column '", label, "' not found in result$result.")
  }
  
  # Check if color column exists
  if (!is.null(color) && !(color %in% names(df))) {
    stop("Color column '", color, "' not found in result$result.")
  }
  
  # Check if threshold vectors are valid
  if (!is.null(label.parameter.threshold)) {
    if (!is.numeric(label.parameter.threshold)|length(label.parameter.threshold)>1) {
      stop("label.parameter.threshold must be a numeric of length 1")
    }
  }
  
  if (!is.null(label.pi.threshold)) {
    if (!is.numeric(label.pi.threshold)|length(label.pi.threshold)>1) {
      stop("label.pi.threshold must be a numeric of length 1")
    }
  }
  
  if (!(is.character(title)&is.character(xlab))){
      stop("'xlab' and 'title' must be character values")
  }
  
  if (!is.logical(c(CrI))) {
    stop("'CrI' must be either 'TRUE' or 'FALSE'")
  }
  
  # Binding of global variables
  parameter.median <- NULL
  pi.value <- NULL
  parameter.low <- NULL
  parameter.high <- NULL
  
  # create base plot ####
  ## get threshold
  t <- result$meta$zero.effect
  
  subtitle <- paste0("vertical black line: zero effect of parameter = ",t)
  
  p <- ggplot(df,(aes(x=parameter.median,y=pi.value))) +
    geom_point()+
    theme_bw()+
    # mark user set zero.effect
    geom_vline(aes(xintercept=t))+
    xlab(xlab)+
    ylab("pi")+
    ggtitle(title, subtitle)
  
  # add errorbar ####
  if(CrI==TRUE){
    
    subtitle <- paste0(subtitle,'\n',
"errorbar: CrI ",result$meta$CrI.low,", ",result$meta$CrI.high)
    
    p <- p+
      geom_errorbar(aes(xmin=parameter.low,xmax=parameter.high),col="grey")+
      ggtitle(title, subtitle)
  }
  
  # add color ####
  if(!is.null(color)){
    if(is.numeric(df[[color]])){
    temp <- as.symbol(color)
    temp <- enquo(temp)
    p <- p+
      geom_point(aes(col = !!temp))+
      scale_color_viridis_c()
    }
    if(is.character(df[[color]])){
      temp <- as.symbol(color)
      temp <- enquo(temp)
      p <- p+
        geom_point(aes(col = !!temp))+
        scale_color_viridis_d()
    }
  }
  
  # add label ####
  if(!is.null(label)){
    # make useable for ggplot
    temp <- as.symbol(label)
    temp <- enquo(temp)
    # if null set to zero
    if(is.null(label.parameter.threshold)){
      label.parameter.threshold <- 0
    }
    if(is.null(label.pi.threshold)){
      label.pi.threshold <- 0
    }
    
    subtitle <- paste0(subtitle,'\n',
                       paste0("grey lines: label thresholds, |parameter| > ",
                              label.parameter.threshold,", pi > ",label.pi.threshold))
    
    
    p <- p+
      geom_text_repel(aes(label=ifelse(abs(parameter.median)>label.parameter.threshold&pi.value>label.pi.threshold,
                                       yes = !!temp,no ="")))+
      geom_vline(aes(xintercept = label.parameter.threshold),col="grey")+
      geom_vline(aes(xintercept = -label.parameter.threshold),col="grey")+
      geom_hline(aes(yintercept = label.pi.threshold),col="grey")+
      ggtitle(title, subtitle)
  }
  
  return(p)
}
  