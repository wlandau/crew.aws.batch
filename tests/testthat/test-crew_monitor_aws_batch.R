test_that("crew_monitor_aws_batch()", {
  out <- crew_monitor_aws_batch(
    job_queue = "job_queue_name",
    job_definition = "job_definition_name",
    log_group = "/aws/batch/job",
    config = list(config = TRUE),
    credentials = list(credentials = TRUE),
    endpoint = "endpoint_url",
    region = "us-east-2"
  )
  expect_silent(out$validate())
  expect_equal(out$job_queue, "job_queue_name")
  expect_equal(out$job_definition, "job_definition_name")
  expect_equal(out$log_group, "/aws/batch/job")
  expect_equal(out$config, list(config = TRUE))
  expect_equal(out$credentials, list(credentials = TRUE))
  expect_equal(out$endpoint, "endpoint_url")
  expect_equal(out$region, "us-east-2")
})

test_that("crew_monitor_aws_batch() private$.client()", {
  skip_on_cran()
  x <- crew_monitor_aws_batch(
    job_queue = "x",
    job_definition = "y",
    region = "us-east-2"
  )
  out <- x$.__enclos_env__$private$.client()
  expect_true(is.function(out$list_jobs))
})
