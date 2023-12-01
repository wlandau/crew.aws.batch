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

test_that("crew_controller_aws_batch() sync mock launch and termination", {
  controller <- crew_controller_aws_batch(
    processes = NULL,
    aws_batch_config = structure(list(), class = "crew_aws_batch_debug"),
    aws_batch_job_definition = "crew-aws-batch",
    aws_batch_job_queue = "crew-aws-batch"
  )
  controller$start()
  on.exit(controller$terminate())
  controller$launch(n = 1L)
  name <- controller$launcher$workers$handle[[1L]]$data$jobId
  socket <- controller$launcher$workers$socket
  out <- tail(strsplit(name, split = "-", fixed = TRUE)[[1L]], n = 1L)
  exp <- tail(strsplit(socket, split = "/", fixed = TRUE)[[1L]], n = 1L)
  expect_equal(out, exp)
  expect_silent(controller$terminate())
  out <- controller$launcher$workers$termination[[1L]]$data$value
  expect_true(is.integer(out) && length(out) == 1L && is.finite(out))
})

test_that("crew_controller_aws_batch() async mock launch and termination", {
  skip_on_cran()
  skip_on_os("windows")
  controller <- crew_controller_aws_batch(
    processes = 1L,
    aws_batch_config = structure(list(), class = "crew_aws_batch_debug"),
    aws_batch_job_definition = "crew-aws-batch",
    aws_batch_job_queue = "crew-aws-batch"
  )
  controller$start()
  on.exit(controller$terminate())
  controller$launch(n = 1L)
  controller$launcher$wait()
  name <- controller$launcher$workers$handle[[1L]]$data$jobId
  socket <- controller$launcher$workers$socket
  out <- tail(strsplit(name, split = "-", fixed = TRUE)[[1L]], n = 1L)
  exp <- tail(strsplit(socket, split = "/", fixed = TRUE)[[1L]], n = 1L)
  expect_equal(out, exp)
  expect_silent(controller$terminate())
  controller$launcher$wait()
  out <- controller$launcher$workers$termination[[1L]]$data$value
  expect_true(is.integer(out) && length(out) == 1L && is.finite(out))
})
