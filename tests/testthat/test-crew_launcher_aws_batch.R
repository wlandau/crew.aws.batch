test_that("AWS batch launcher", {
  options <- crew_options_aws_batch(
    job_definition = "crew-definition",
    job_queue = "crew-queue",
    cpus = 2.5,
    gpus = 3,
    memory = 1234,
    memory_units = "mebibytes"
  )
  x <- crew_launcher_aws_batch(options_aws_batch = options)
  expect_silent(x$validate())
  nonempty <- !vapply(options, is.null, FUN.VALUE = logical(1L))
  expect_s3_class(x$options_aws_batch, "crew_options_aws_batch")
  expect_s3_class(x$options_aws_batch, "crew_options")
  for (name in names(x$options_aws_batch)) {
    expect_equal(x$options_aws_batch[[name]], options[[name]])
  }
  private <- crew_private(x)
  expect_true(is.list(private$.args_client()))
  expect_equal(
    sort(names(private$.args_client())),
    sort(c("config", "credentials", "endpoint", "region"))
  )
  out <- private$.args_submit(call = "run", name = "x")
  expect_true(is.list(out))
  expect_equal(out$jobName, "x")
  expect_equal(out$jobDefinition, "crew-definition")
  expect_equal(out$jobQueue, "crew-queue")
  expect_equal(
    out$containerOverrides,
    list(
      resourceRequirements = list(
        memory = list(value = "1234", type = "MEMORY"),
        cpus = list(value = "2.5", type = "VCPU"),
        gpus = list(value = "3", type = "GPU")
      ),
      command = list("Rscript", "-e", "run")
    )
  )
})

test_that("crew_aws_batch_job_name() long string", {
  long <- paste(c("_", rep("x", 200L)), collapse = "")
  out <- crew_aws_batch_job_name(long)
  expect_equal(out, paste(c("x", "_", rep("x", 126L)), collapse = ""))
})

test_that("crew_aws_batch_job_name() invalid name", {
  invalid <- "_crew-dot.dot.dot.-1-0d00c9d722fed4e4f3be1c35"
  out <- crew_aws_batch_job_name(invalid)
  expect_equal(out, "x_crew-dot_dot_dot_-1-0d00c9d722fed4e4f3be1c35")
})
