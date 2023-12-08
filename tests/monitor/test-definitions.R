library(crew.aws.batch)
library(testthat)

test_that("job definition management", {
  x <- crew_aws_batch_monitor(
    job_definition = "crew-aws-batch-test",
    job_queue = "crew-aws-batch-job-queue",
    region = "us-east-2"
  )
  out <- x$register(
    image = "alpine:latest",
    platform_capabilities = "EC2",
    memory_units = "gigabytes",
    memory = 1,
    cpus = 1,
    seconds_timeout = 600,
    scheduling_priority = 3,
    tags = c("crew_aws_batch_1", "crew_aws_batch_2"),
    propagate_tags = TRUE
  )
  expect_equal(nrow(out), 1L)
  expect_equal(out$name, x$job_definition)
  out <- x$describe()
  expect_equal(nrow(out), 1L)
  expect_equal(out$jobDefinitionName, x$job_definition)
  for (index in seq_len(2L)) {
    expect_null(x$deregister())
  }
})
