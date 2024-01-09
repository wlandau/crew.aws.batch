test_that("private methods", {
  x <- crew_launcher_aws_batch(
    aws_batch_job_definition = "crew-aws-batch",
    aws_batch_job_queue = "crew-aws-batch"
  )
  private <- crew_private(x)
  expect_true(is.list(private$.args_client()))
  expect_equal(
    sort(names(private$.args_client())),
    sort(c("config", "credentials", "endpoint", "region"))
  )
  out <- private$.args_submit(call = "run", name = "x")
  expect_true(is.list(out))
  expect_equal(out$jobName, "x")
  expect_equal(out$jobQueue, "crew-aws-batch")
})
