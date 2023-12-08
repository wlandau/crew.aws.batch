library(crew.aws.batch)
library(testthat)

test_that("empty job list", {
  x <- crew_aws_batch_monitor(
    job_definition = "never-existed",
    job_queue = "crew-aws-batch-job-queue",
    region = "us-east-2"
  )
  expect_equal(nrow(x$jobs()), 0L)
  expect_equal(nrow(x$status(id = "does-not-exist")), 0L)
  expect_null(x$log(id = "does-not-exist"))
})

test_that("job list", {
  x <- crew_aws_batch_monitor(
    job_definition = "crew-aws-batch-test",
    job_queue = "crew-aws-batch-job-queue",
    region = "us-east-2"
  )
  x$register(
    image = "alpine:latest",
    platform_capabilities = "EC2",
    memory_units = "gigabytes",
    memory = 1,
    cpus = 1,
    seconds_timeout = 600,
    tags = c("crew_aws_batch_1", "crew_aws_batch_2"),
    propagate_tags = TRUE
  )
  on.exit(x$deregister())
  x$submit(
    command = c("sleep", "300"),
    memory_units = "gigabytes",
    memory = 1,
    cpus = 1,
    seconds_timeout = 600,
    tags = c("crew_aws_batch_1", "crew_aws_batch_2"),
    propagate_tags = TRUE
  )
  job <- x$submit()
  expect_equal(nrow(x$status(id = job$id)), 1L)
  expect_true(tibble::is_tibble(jobs <- x$jobs()))
  expect_true(tibble::is_tibble(submitted <- x$submitted()))
  expect_true(tibble::is_tibble(active <- x$active()))
  expect_true(tibble::is_tibble(inactive <- x$inactive()))
  expect_true(tibble::is_tibble(pending <- x$pending()))
  expect_true(tibble::is_tibble(runnable <- x$runnable()))
  expect_true(tibble::is_tibble(running <- x$running()))
  expect_true(tibble::is_tibble(succeeded <- x$succeeded()))
  expect_true(tibble::is_tibble(failed <- x$failed()))
  expect_true(nrow(jobs) > 0L)
  exp <- nrow(submitted) +
    nrow(pending) +
    nrow(runnable) +
    nrow(running) +
    nrow(succeeded) +
    nrow(failed)
  expect_equal(nrow(jobs), exp)
  expect_true(job$name %in% jobs$name)
  expect_true(job$id %in% jobs$id)
  expect_true(job$arn %in% jobs$arn)
  info <- x$status(id = job$id)
  expect_true(is.na(info$reason))
  expect_false(info$status %in% c("succeeded", "failed"))
  good_reason <- "I have my reasons..."
  x$terminate(id = info$id, reason = good_reason)
  attempts <- 0
  while (!info$status %in% c("succeeded", "failed")) {
    message(
      paste(
        "checking terminated job",
        sample(c("-", "\\", "|", "/"), size = 1L)
      )
    )
    info <- x$status(id = job$id)
    attempts <- attempts + 1L
    if (attempts > 20L) {
      stop("job did not terminate")
    }
    Sys.sleep(5)
  }
  expect_true(info$status %in% c("succeeded", "failed"))
  expect_equal(info$reason, good_reason)
})

test_that("job logs", {
  x <- crew_aws_batch_monitor(
    job_definition = "crew-aws-batch-test",
    job_queue = "crew-aws-batch-job-queue",
    region = "us-east-2"
  )
  x$register(
    image = "alpine:latest",
    platform_capabilities = "EC2",
    memory_units = "gigabytes",
    memory = 1,
    cpus = 1,
    seconds_timeout = 600,
    tags = c("crew_aws_batch_1", "crew_aws_batch_2"),
    propagate_tags = TRUE
  )
  on.exit(x$deregister())
  job <- x$submit(
    command = c("echo", "done with container\ndone with job"),
    memory_units = "mebibytes",
    memory = 128,
    cpus = 1
  )
  attempts <- 0L
  done <- c("succeeded", "failed")
  while (!((status <- x$status(id = job$id)$status) %in% done)) {
    message(
      paste(
        "job status:",
        status,
        sample(c("-", "\\", "|", "/"), size = 1L)
      )
    )
    attempts <- attempts + 1L
    if (attempts > 60L) {
      stop("job did not finish")
    }
    Sys.sleep(5)
  }
  log <- x$log(id = job$id)
  expect_true(tibble::is_tibble(log))
  expect_equal(log$message, c("done with container", "done with job"))
})
