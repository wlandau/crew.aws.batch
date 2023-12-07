test_that("crew_aws_batch_job_definition()", {
  out <- crew_aws_batch_job_definition(
    name = "job_definition_name"
  )
  expect_silent(out$validate())
  expect_equal(out$name, "job_definition_name")
})
