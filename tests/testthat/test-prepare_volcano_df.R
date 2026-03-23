# tests/testthat/test-input-validation.R

# Input tests ####

test_that("Function throws error if posterior is not a data frame", {
  expect_error(
    prepare_volcano_df(posterior = 1:100, annotation_df = data.frame(parameter = "a", label = "b")),
    "Argument 'posterior' must be a data frame."
  )
})

test_that("Function throws error if zero.effect is not numeric", {
  expect_error(
    prepare_volcano_df(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation_df = data.frame(parameter = "doubling.1", label = "test"),
      zero.effect = "0.05"
    ),
    "zero.effect has to be numeric"
  )
})

test_that("Function throws error if CrI.low is not numeric", {
  expect_error(
    prepare_volcano_df(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation_df = data.frame(parameter = "doubling.1", label = "test"),
      CrI.low = "0.025"
    ),
    "CrI.low and CrI.high must be numeric."
  )
})

test_that("Function throws error if CrI.high is not numeric", {
  expect_error(
    prepare_volcano_df(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation_df = data.frame(parameter = "doubling.1", label = "test"),
      CrI.high = "0.975"
    ),
    "CrI.low and CrI.high must be numeric."
  )
})

test_that("Function throws error if CrI.low < 0", {
  expect_error(
    prepare_volcano_df(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation_df = data.frame(parameter = "doubling.1", label = "test"),
      CrI.low = -0.1
    ),
    "CrI.low and CrI.high must be between 0 and 1, and CrI.low < CrI.high."
  )
})

test_that("Function throws error if CrI.high > 1", {
  expect_error(
    prepare_volcano_df(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation_df = data.frame(parameter = "doubling.1", label = "test"),
      CrI.high = 1.1
    ),
    "CrI.low and CrI.high must be between 0 and 1, and CrI.low < CrI.high."
  )
})

test_that("Function throws error if CrI.low >= CrI.high", {
  expect_error(
    prepare_volcano_df(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation_df = data.frame(parameter = "doubling.1", label = "test"),
      CrI.low = 0.5,
      CrI.high = 0.5
    ),
    "CrI.low and CrI.high must be between 0 and 1, and CrI.low < CrI.high."
  )
})

test_that("Function throws error if annotation_df is not a data frame", {
  expect_error(
    prepare_volcano_df(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation_df = list(parameter = "a", label = "b")
    ),
    "Argument 'annotation_df' must be a data frame."
  )
})

test_that("Function throws error if annotation_df lacks 'parameter' column", {
  expect_error(
    prepare_volcano_df(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation_df = data.frame(label = "test")
    ),
    "annotation_df has to contain a column 'paramter'"
  )
})

test_that("Function throws error if annotation_df lacks 'label' column", {
  expect_error(
    prepare_volcano_df(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation_df = data.frame(parameter = "doubling.1")
    ),
    "annotation_df has to contain a column 'label'"
  )
})

test_that("Function handles missing parameter in posterior correctly", {
  posterior <- data.frame(doubling.1 = rnorm(100))
  annotation_df <- data.frame(
    parameter = c("doubling.1", "doubling.2"),
    label = c("A", "B")
  )
  
  result <- prepare_volcano_df(posterior = posterior, annotation_df = annotation_df)
  
  # Should not throw error, but should return only existing parameter
  expect_equal(nrow(result$result), 1)
  expect_equal(result$result$parameter, "doubling.1")
})

# Output tests ####
test_that("Function returns a list with 'result' and 'meta' components", {
  posterior <- data.frame(
    doubling.1 = rnorm(1000),
    doubling.2 = rnorm(1000)
  )
  
  annotation_df <- data.frame(
    parameter = c("doubling.1", "doubling.2"),
    label = c("cell.line.A", "cell.line.B"),
    group = c("group1", "group1")
  )
  
  result <- prepare_volcano_df(posterior = posterior, annotation_df = annotation_df)
  
  expect_type(result, "list")
  expect_true("result" %in% names(result))
  expect_true("meta" %in% names(result))
})

test_that("Result data frame has correct columns", {
  posterior <- data.frame(doubling.1 = rnorm(1000))
  annotation_df <- data.frame(parameter = "doubling.1", label = "test")
  
  result <- prepare_volcano_df(posterior = posterior, annotation_df = annotation_df)
  
  expected_cols <- c(
    "parameter", "pi.value", "parameter.median", "parameter.low", "parameter.high", "label"
  )
  
  expect_true(all(expected_cols %in% names(result$result)))
})

test_that("pi.value is computed correctly for zero.effect = 0", {
  # Simulate data where 50% of values are above and below 0 -> pi should be 0
  posterior <- data.frame(doubling.1 = c(rep(-1, 500), rep(1, 500)))
  annotation_df <- data.frame(parameter = "doubling.1", label = "test")
  
  result <- prepare_volcano_df(posterior = posterior, annotation_df = annotation_df, zero.effect = 0)
  
  expect_equal(result$result$pi.value, 0, tolerance = 0.01)
})

test_that("pi.value is computed correctly for zero.effect = 1", {
  # All values are below 1 → pi = 1
  posterior <- data.frame(doubling.1 = rnorm(1000, mean = 0, sd = 0.1))
  annotation_df <- data.frame(parameter = "doubling.1", label = "test")
  
  result <- prepare_volcano_df(posterior = posterior, annotation_df = annotation_df, zero.effect = 2)
  
  expect_equal(result$result$pi.value, 1.0, tolerance = 0.01)
})

test_that("median is computed correctly", {
  posterior <- data.frame(doubling.1 = c(1, 2, 3, 4, 5))
  annotation_df <- data.frame(parameter = "doubling.1", label = "test")
  
  result <- prepare_volcano_df(posterior = posterior, annotation_df = annotation_df)
  
  expect_equal(result$result$parameter.median, 3)
})

test_that("CrI bounds are computed correctly", {
  posterior <- data.frame(doubling.1 = rnorm(1000, mean = 0, sd = 1))
  annotation_df <- data.frame(parameter = "doubling.1", label = "test")
  
  result <- prepare_volcano_df(
    posterior = posterior,
    annotation_df = annotation_df,
    CrI.low = 0.025,
    CrI.high = 0.975
  )
  
  # Check that CrI bounds are close to theoretical 95% CI
  expected_low <- as.numeric(quantile(posterior$doubling.1, 0.025))
  expected_high <- as.numeric(quantile(posterior$doubling.1, 0.975))
  
  expect_equal(result$result$parameter.low, expected_low, tolerance = 0.1)
  expect_equal(result$result$parameter.high, expected_high, tolerance = 0.1)
})

test_that("Left join with annotation_df preserves additional columns", {
  posterior <- data.frame(doubling.1 = rnorm(1000))
  annotation_df <- data.frame(
    parameter = "doubling.1",
    label = "cell.line.A",
    group = "treatment",
    condition = "high"
  )
  
  result <- prepare_volcano_df(posterior = posterior, annotation_df = annotation_df)
  
  expect_equal(names(result$result), c(
    "parameter", "pi.value", "parameter.median", "parameter.low", "parameter.high",
    "CrI.width","label", "group", "condition"
  ))
})

test_that("meta list contains correct settings", {
  posterior <- data.frame(doubling.1 = rnorm(1000))
  annotation_df <- data.frame(parameter = "doubling.1", label = "test")
  
  result <- prepare_volcano_df(
    posterior = posterior,
    annotation_df = annotation_df,
    zero.effect = 0.1,
    CrI.low = 0.05,
    CrI.high = 0.95
  )
  
  expect_equal(result$meta$zero.effect, 0.1)
  expect_equal(result$meta$CrI.low, 0.05)
  expect_equal(result$meta$CrI.high, 0.95)
})
