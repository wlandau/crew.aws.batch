test_that("crew_controller_aws_batch() can create a valid object", {
  controller <- crew_controller_aws_batch(
    aws_batch_job_definition = "crew-aws-batch",
    aws_batch_job_queue = "crew-aws-batch"
  )
  expect_silent(controller$validate())
})

test_that("active bindings", {
  controller <- crew_controller_aws_batch(
    aws_batch_job_definition = "crew-aws-batch",
    aws_batch_job_queue = "crew-aws-batch"
  )
  expect_null(controller$launcher$aws_batch_scheduling_priority_override)
})
