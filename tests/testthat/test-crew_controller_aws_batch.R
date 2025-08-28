test_that("AWS batch controller", {
  options <- crew_options_aws_batch(
    job_definition = "crew-definition",
    job_queue = "crew-queue",
    cpus = 2.5,
    gpus = 3,
    memory = 1234,
    memory_units = "mebibytes"
  )
  x <- crew_controller_aws_batch(options_aws_batch = options)
  expect_silent(x$validate())
  nonempty <- !vapply(options, is.null, FUN.VALUE = logical(1L))
  expect_s3_class(x$launcher$options_aws_batch, "crew_options_aws_batch")
  expect_s3_class(x$launcher$options_aws_batch, "crew_options")
  for (name in names(x$launcher$options_aws_batch)) {
    expect_equal(x$launcher$options_aws_batch[[name]], options[[name]])
  }
  private <- crew_private(x$launcher)
  expect_true(is.list(private$.args_client()))
  expect_equal(
    sort(names(private$.args_client())),
    sort(c("config", "credentials", "endpoint", "region"))
  )
  out <- private$.args_submit(call = "run", name = "x", n = 2L)
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
  expect_equal(out$arrayProperties, list(size = 2L))
  out <- private$.args_submit(call = "run", name = "x", n = 1L)
  expect_null(out$arrayProperties)
})

test_that("AWS batch controller deprecated retryable options", {
  skip_on_cran()
  expect_message(
    options <- crew_options_aws_batch(
      job_definition = "crew-definition",
      job_queue = "crew-queue",
      cpus = c(2.5, 3.5, 1.7),
      gpus = c(3, 2),
      memory = c(1234, 1157),
      memory_units = "mebibytes"
    ),
    class = "crew_deprecate"
  )
  x <- crew_controller_aws_batch(options_aws_batch = options)
  private <- crew_private(x$launcher)
  out <- private$.args_submit(call = "run", name = "x", n = 2L)
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

# https://github.com/wlandau/crew/issues/217
test_that("crew_controller_aws_batch() cleanup deprecations", {
  options <- crew_options_aws_batch(
    job_definition = "crew-definition",
    job_queue = "crew-queue"
  )
  x <- crew_controller_aws_batch(options_aws_batch = options)
  fields <- c(
    "reset_globals",
    "reset_packages",
    "reset_globals",
    "garbage_collection"
  )
  for (field in fields) {
    expect_true(is.logical(x[[field]]))
    expect_null(x$launcher[[field]])
  }
})
