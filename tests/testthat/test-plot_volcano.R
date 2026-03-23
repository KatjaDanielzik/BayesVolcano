# Simulate minimal data to test the function
df <- data.frame(
  parameter.median = c(-1.5, -0.3, 0.2, 1.2, 0.0),
  pi.value = c(0.95, 0.1, 0.8, 0.99, 0.5),
  parameter.low = c(-2.0, -0.5, -0.1, 0.8, -0.2),
  parameter.high = c(-1.0, -0.1, 0.5, 1.6, 0.2),
  label = c("A", "B", "C", "D", "E"),
  group = c("Control", "Treatment", "Control", "Treatment", "Control")
)

meta <- list(
  threshold = 0.5,
  CrI.low = 0.025,
  CrI.high = 0.975
)

test_data <- list(result = df, meta = meta)

# Test 1: Input validation - result must be a list with 'result' and 'meta'
test_that("plot_volcano fails with invalid result", {
  expect_error(plot_volcano(NULL), "Argument 'result' must be a list with 'result' and 'meta' components from prepare_volcano_df().")
  expect_error(plot_volcano(list(result = data.frame())), "Argument 'result' must be a list with 'result' and 'meta' components from prepare_volcano_df().")
  expect_error(plot_volcano(list(meta = list(threshold = 0.5))), "Argument 'result' must be a list with 'result' and 'meta' components from prepare_volcano_df().")
})

# Test 2: Label column must exist
test_that("plot_volcano fails if label column does not exist", {
  expect_error(plot_volcano(test_data, label = "nonexistent"), "Label column 'nonexistent' not found")
})

# Test 3: Color column must exist
test_that("plot_volcano fails if color column does not exist", {
  expect_error(plot_volcano(test_data, color = "nonexistent"), "Color column 'nonexistent' not found")
})

# Test 4: label.parameter.threshold and label.pi.threshold must be numeric
test_that("plot_volcano fails if thresholds are not numeric", {
  expect_error(plot_volcano(test_data, label.parameter.threshold = "abc"), "label.parameter.threshold must be a numeric of length 1")
  expect_error(plot_volcano(test_data, label.pi.threshold = c(1, 2)), "label.pi.threshold must be a numeric of length 1")
})

# Test 5: title and xlab must be character
test_that("plot_volcano fails if title or xlab are not character", {
  expect_error(plot_volcano(test_data, title = 123), "'xlab' and 'title' must be character values")
  expect_error(plot_volcano(test_data, xlab = 456), "'xlab' and 'title' must be character values")
})

# Test 6: CrI must be logical
test_that("plot_volcano fails if CrI is not logical", {
  expect_error(plot_volcano(test_data, CrI = "TRUE"), "'CrI' must be either 'TRUE' or 'FALSE'")
  expect_error(plot_volcano(test_data, CrI = 1), "'CrI' must be either 'TRUE' or 'FALSE'")
})

# Test 7: Returns a ggplot object when valid inputs are provided
test_that("plot_volcano returns a ggplot object", {
  p <- plot_volcano(
    result = test_data,
    color = "group",
    label = "label",
    label.parameter.threshold = 0.5,
    label.pi.threshold = 0.8,
    title = "Test Volcano",
    xlab = "Parameter Estimate"
  )

  expect_s3_class(p, "ggplot")
  expect_true(inherits(p, "ggplot"))
})

# Test 8: CrI = TRUE updates subtitle
test_that("CrI = TRUE adds errorbar and updates subtitle", {
  p <- plot_volcano(test_data, CrI = TRUE)

  # Check subtitle contains CrI info
  subtitle <- p$labels$subtitle
  expect_true(grepl("errorbar: CrI 0.025, 0.975", subtitle))
})

# Test 8: label is not NULL updates subtitle
test_that("label is not NULL  updates subtitle", {
  p <- plot_volcano(test_data, label = "label")

  # Check subtitle contains CrI info
  subtitle <- p$labels$subtitle
  expect_true(grepl("grey lines: label thresholds", subtitle))
})
