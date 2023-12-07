test_that("crew_aws_batch_monitor()", {
  out <- crew_aws_batch_monitor(
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
