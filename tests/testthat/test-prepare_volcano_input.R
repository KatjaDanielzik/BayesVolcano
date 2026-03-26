# Input tests ####

test_that("Function throws error if posterior is not a data frame", {
  expect_error(
    prepare_volcano_input(posterior = 1:100, annotation = data.frame(parameter = "a", label = "b")),
    "Argument 'posterior' must be a data frame."
  )
})

test_that("Function throws error if null.effect is not numeric", {
  expect_error(
    prepare_volcano_input(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation = data.frame(parameter = "doubling.1", label = "test"),
      null.effect = "0.05"
    ),
    "null.effect must be numeric"
  )
})

test_that("Function throws error if CrI_level is not numeric", {
  expect_error(
    prepare_volcano_input(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation = data.frame(parameter = "doubling.1", label = "test"),
      CrI_level = "0.025"
    ),
    "CrI_level must be numeric and in between 0 and 1"
  )
})

test_that("Function throws error if CrI_level is <0", {
  expect_error(
    prepare_volcano_input(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation = data.frame(parameter = "doubling.1", label = "test"),
      CrI_level = -0.1
    ),
    "CrI_level must be numeric and in between 0 and 1"
  )
})

test_that("Function throws error if CrI_level is >1", {
  expect_error(
    prepare_volcano_input(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation = data.frame(parameter = "doubling.1", label = "test"),
      CrI_level = 1.2
    ),
    "CrI_level must be numeric and in between 0 and 1"
  )
})


test_that("Function throws error if annotation is not a data frame", {
  expect_error(
    prepare_volcano_input(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation = list(parameter = "a", label = "b")
    ),
    "Argument 'annotation' must be a data frame."
  )
})

test_that("Function throws error if annotation lacks 'parameter' column", {
  expect_error(
    prepare_volcano_input(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation = data.frame(label = "test")
    ),
    "annotation must contain a column 'paramter'"
  )
})

test_that("Function throws error if annotation lacks 'label' column", {
  expect_error(
    prepare_volcano_input(
      posterior = data.frame(doubling.1 = rnorm(100)),
      annotation = data.frame(parameter = "doubling.1")
    ),
    "annotation must contain a column 'label'"
  )
})

test_that("Function handles missing parameter in posterior correctly", {
  posterior <- data.frame(doubling.1 = rnorm(100))
  annotation <- data.frame(
    parameter = c("doubling.1", "doubling.2"),
    label = c("A", "B")
  )

  result <- prepare_volcano_input(posterior = posterior, annotation = annotation)

  # Should not throw error, but should return only existing parameter
  expect_equal(nrow(result), 1)
  expect_equal(result$parameter, "doubling.1")
})

# Output tests ####
test_that("Function returns a data frame", {
  posterior <- data.frame(
    doubling.1 = rnorm(1000),
    doubling.2 = rnorm(1000)
  )

  annotation <- data.frame(
    parameter = c("doubling.1", "doubling.2"),
    label = c("cell.line.A", "cell.line.B"),
    group = c("group1", "group1")
  )

  result <- prepare_volcano_input(posterior = posterior, annotation = annotation)

  expect_s3_class(result, "data.frame")
})

test_that("Result data frame has correct columns", {
  posterior <- data.frame(doubling.1 = rnorm(1000))
  annotation <- data.frame(parameter = "doubling.1", label = "test")

  result <- prepare_volcano_input(posterior = posterior, annotation = annotation)

  expected_cols <- c(
    "parameter", "pi.value", "parameter.median", "parameter.low", "parameter.high", "label"
  )

  expect_true(all(expected_cols %in% names(result)))
})

test_that("pi.value is computed correctly for null.effect = 0", {
  # Simulate data where 50% of values are above and below 0 -> pi should be 0
  posterior <- data.frame(doubling.1 = c(rep(-1, 500), rep(1, 500)))
  annotation <- data.frame(parameter = "doubling.1", label = "test")

  result <- prepare_volcano_input(posterior = posterior, annotation = annotation, null.effect = 0)

  expect_equal(result$pi.value, 0, tolerance = 0.01)
})

test_that("Left join with annotation preserves additional columns", {
  posterior <- data.frame(doubling.1 = rnorm(1000))
  annotation <- data.frame(
    parameter = "doubling.1",
    label = "cell.line.A",
    group = "treatment",
    condition = "high"
  )

  result <- prepare_volcano_input(posterior = posterior, annotation = annotation)

  expect_equal(names(result), c(
    "parameter", "pi.value", "null.effect", "parameter.median", "parameter.low", "parameter.high",
    "CrI.width", "CrI.level", "label", "group", "condition"
  ))
})
