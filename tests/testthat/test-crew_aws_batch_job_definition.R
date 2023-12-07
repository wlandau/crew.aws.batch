test_that("crew_aws_batch_job_definition()", {
  out <- crew_aws_batch_job_definition(
    name = "job_definition_name",
    log_group = "/aws/batch/job",
    log_group_region = "us-east-2"
  )
  expect_silent(out$validate())
  expect_equal(out$name, "job_definition_name")
  expect_equal(out$log_group, "/aws/batch/job")
  expect_equal(out$log_group_region, "us-east-2")
})
