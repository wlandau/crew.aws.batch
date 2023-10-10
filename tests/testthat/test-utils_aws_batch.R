test_that("real client", {
  client <- crew_aws_batch_client(args = list(region = "us-west-2"))
  expect_true(is.function(client$create_compute_environment))
})

test_that("mock client", {
  config <- structure(list(), class = "crew_aws_batch_debug")
  client <- crew_aws_batch_client(config = config)
  expect_false(is.function(client$create_compute_environment))
})

test_that("mock client submit method",  {
  config <- structure(list(), class = "crew_aws_batch_debug")
  client <- crew_aws_batch_client(config = config)
  out <- client$submit_job(
    jobName = "job_name",
    jobQueue = "job_queue",
    shareIdentifier = "x",
    schedulingPriorityOverride = "x",
    jobDefinition = "job_definition",
    parameters = "x",
    containerOverrides = "x",
    nodeOverrides = "x",
    retryStrategy = "x",
    propagateTags = "x",
    timeout = "x",
    tags = "x",
    eksPropertiesOverride = "x"
  )
  expect_equal(out, list(jobId = "job_name"))
})

test_that("mock client terminate method",  {
  config <- structure(list(), class = "crew_aws_batch_debug")
  client <- crew_aws_batch_client(config = config)
  out <- client$terminate_job(jobId = "this_job", reason = "because test")
  expect_true(is.list(out))
  expect_true(is.numeric(out$value))
})

test_that("mock submit helper", {
  config <- structure(list(), class = "crew_aws_batch_debug")
  args_client <- list(config = config)
  args_submit <- list(
    jobName = "job_name",
    jobQueue = "job_queue",
    shareIdentifier = "x",
    schedulingPriorityOverride = "x",
    jobDefinition = "job_definition",
    parameters = "x",
    containerOverrides = "x",
    nodeOverrides = "x",
    retryStrategy = "x",
    propagateTags = "x",
    timeout = "x",
    tags = "x",
    eksPropertiesOverride = "x"
  )
  out <- crew_aws_batch_launch(
    args_client = args_client,
    args_submit = args_submit
  )
  expect_equal(out, list(jobId = "job_name"))
})

test_that("mock terminate helper", {
  config <- structure(list(), class = "crew_aws_batch_debug")
  args_client <- list(config = config)
  out <- crew_aws_batch_terminate(args_client = args_client, job_id = "x")
  expect_true(is.list(out))
  expect_true(is.numeric(out$value))
})
