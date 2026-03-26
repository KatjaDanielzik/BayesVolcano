# Simulate minimal data to test the function
test_data <- data.frame(
  parameter.median = c(-1.5, -0.3, 0.2, 1.2, 0.0),
  pi.value = c(0.95, 0.1, 0.8, 0.99, 0.5),
  null.effect = 0,
  parameter.low = c(-2.0, -0.5, -0.1, 0.8, -0.2),
  parameter.high = c(-1.0, -0.1, 0.5, 1.6, 0.2),
  CrI.width = 0.8,
  CrI.level = 0.95,
  label = c("A", "B", "C", "D", "E"),
  group = c("Control", "Treatment", "Control", "Treatment", "Control")
)

# Input validation - result must be a list with 'result' and 'meta'
test_that("plot_volcano fails with invalid result", {
  expect_error(plot_volcano(NULL), "'result' must be a data frame")
})

#  CrI must be logical
test_that("plot_volcano fails if CrI is not logical", {
  expect_error(plot_volcano(test_data, CrI = "TRUE"), "'CrI' must be either 'TRUE' or 'FALSE'")
  expect_error(plot_volcano(test_data, CrI = 1), "'CrI' must be either 'TRUE' or 'FALSE'")
})

# CrI_level must be logical
test_that("plot_volcano fails if CrI_level is not logical", {
  expect_error(plot_volcano(test_data, CrI_width = "TRUE"), "'CrI_width' must be either 'TRUE' or 'FALSE'")
  expect_error(plot_volcano(test_data, CrI_width = 1), "'CrI_width' must be either 'TRUE' or 'FALSE'")
})

# Returns a ggplot object when valid inputs are provided
test_that("plot_volcano returns a ggplot object", {
  p <- plot_volcano(
    result = test_data,
    CrI = TRUE,
    CrI_width = TRUE
  )

  expect_s3_class(p, "ggplot")
  expect_true(inherits(p, "ggplot"))
})

# CrI = TRUE updates subtitle
test_that("CrI = TRUE adds errorbar and updates subtitle", {
  p <- plot_volcano(test_data, CrI = TRUE)

  # Check subtitle contains CrI info
  subtitle <- p$labels$subtitle
  expect_true(grepl("errorbar: 95 % CrI", subtitle))
})
