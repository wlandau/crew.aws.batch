test_that("basic options", {
  out <- crew_options_aws_batch(
    job_definition = "x",
    job_queue = "y"
  )
  expect_s3_class(out, c("crew_options_aws_batch", "crew_options"))
  expect_equal(out$job_definition, "x")
  expect_equal(out$job_queue, "y")
})

test_that("cpu and memory", {
  out <- crew_options_aws_batch(
    job_definition = "x",
    job_queue = "y",
    cpus = 0.5,
    memory = 2,
    memory_units = "gigabytes"
  )
  expect_s3_class(out, c("crew_options_aws_batch", "crew_options"))
  expect_equal(out$job_definition, "x")
  expect_equal(out$job_queue, "y")
  expect_equal(
    out$container_overrides,
    list(
      resourceRequirements = list(
        memory = list(value = "1907", type = "MEMORY"),
        cpus = list(value = "0.5", type = "VCPU")
      )
    )
  )
})

test_that("gpus", {
  out <- crew_options_aws_batch(
    job_definition = "x",
    job_queue = "y",
    gpus = 2
  )
  expect_s3_class(out, c("crew_options_aws_batch", "crew_options"))
  expect_equal(out$job_definition, "x")
  expect_equal(out$job_queue, "y")
  expect_equal(
    out$container_overrides,
    list(
      resourceRequirements = list(
        gpus = list(value = "2", type = "GPU")
      )
    )
  )
})
