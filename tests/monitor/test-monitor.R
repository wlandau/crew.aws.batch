library(crew.aws.batch)
library(testthat)

test_that("empty job list", {
  monitor <- crew_monitor_aws_batch(
    job_definition = "never-existed",
    job_queue = "crew-aws-batch-job-queue",
    region = "us-east-2"
  )
  expect_equal(nrow(monitor$jobs()), 0L)
  expect_equal(nrow(monitor$status(id = "does-not-exist")), 0L)
  expect_true(tibble::is_tibble(monitor$log(id = "does-not-exist")))
})

test_that("job list", {
  definition <- crew_definition_aws_batch(
    job_definition = "crew-aws-batch-test",
    job_queue = "crew-aws-batch-job-queue",
    region = "us-east-2"
  )
  monitor <- crew_monitor_aws_batch(
    job_definition = "crew-aws-batch-test",
    job_queue = "crew-aws-batch-job-queue",
    region = "us-east-2"
  )
  definition$register(
    image = "alpine:latest",
    platform_capabilities = "EC2",
    memory_units = "mebibytes",
    memory = 128,
    cpus = 1,
    seconds_timeout = 600,
    tags = c("crew_aws_batch_1", "crew_aws_batch_2"),
    propagate_tags = TRUE
  )
  on.exit(definition$deregister())
  definition$submit(
    command = c("sleep", "300"),
    memory_units = "mebibytes",
    memory = 128,
    cpus = 1,
    seconds_timeout = 600,
    tags = c("crew_aws_batch_1", "crew_aws_batch_2"),
    propagate_tags = TRUE
  )
  job <- definition$submit()
  expect_equal(nrow(monitor$status(id = job$id)), 1L)
  expect_true(tibble::is_tibble(jobs <- monitor$jobs()))
  expect_true(tibble::is_tibble(submitted <- monitor$submitted()))
  expect_true(tibble::is_tibble(active <- monitor$active()))
  expect_true(tibble::is_tibble(inactive <- monitor$inactive()))
  expect_true(tibble::is_tibble(pending <- monitor$pending()))
  expect_true(tibble::is_tibble(runnable <- monitor$runnable()))
  expect_true(tibble::is_tibble(running <- monitor$running()))
  expect_true(tibble::is_tibble(succeeded <- monitor$succeeded()))
  expect_true(tibble::is_tibble(failed <- monitor$failed()))
  expect_true(nrow(jobs) > 0L)
  expect_true(job$name %in% jobs$name)
  expect_true(job$id %in% jobs$id)
  expect_true(job$arn %in% jobs$arn)
  info <- monitor$status(id = job$id)
  expect_true(is.na(info$reason))
  expect_false(info$status %in% c("succeeded", "failed"))
  good_reason <- "I have my reasons..."
  monitor$terminate(id = info$id, reason = good_reason)
  attempts <- 0
  while (!info$status %in% c("succeeded", "failed")) {
    message(
      paste(
        "checking terminated job with status:",
        info$status,
        sample(c("-", "\\", "|", "/"), size = 1L)
      )
    )
    info <- monitor$status(id = job$id)
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
  definition <- crew_definition_aws_batch(
    job_definition = "crew-aws-batch-test",
    job_queue = "crew-aws-batch-job-queue",
    region = "us-east-2"
  )
  monitor <- crew_monitor_aws_batch(
    job_definition = "crew-aws-batch-test",
    job_queue = "crew-aws-batch-job-queue",
    region = "us-east-2"
  )
  definition$register(
    image = "alpine:latest",
    platform_capabilities = "EC2",
    memory_units = "mebibytes",
    memory = 128,
    cpus = 1,
    seconds_timeout = 600,
    tags = c("crew_aws_batch_1", "crew_aws_batch_2"),
    propagate_tags = TRUE
  )
  on.exit(definition$deregister())
  job <- definition$submit(
    command = c("echo", "done with container\ndone with job"),
    memory_units = "mebibytes",
    memory = 128,
    cpus = 1
  )
  attempts <- 0L
  done <- c("succeeded", "failed")
  while (!((status <- monitor$status(id = job$id)$status) %in% done)) {
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
  log <- monitor$log(id = job$id)
  expect_true(tibble::is_tibble(log))
  expect_equal(log$message, c("done with container", "done with job"))
})

test_that("job terminate", {
  definition <- crew_definition_aws_batch(
    job_definition = "crew-aws-batch-test",
    job_queue = "crew-aws-batch-job-queue",
    region = "us-east-2"
  )
  monitor <- crew_monitor_aws_batch(
    job_definition = "crew-aws-batch-test",
    job_queue = "crew-aws-batch-job-queue",
    region = "us-east-2"
  )
  definition$register(
    image = "alpine:latest",
    platform_capabilities = "EC2",
    memory_units = "mebibytes",
    memory = 128,
    cpus = 1,
    seconds_timeout = 600,
    tags = c("crew_aws_batch_1", "crew_aws_batch_2"),
    propagate_tags = TRUE
  )
  on.exit(definition$deregister())
  n <- 2L
  for (index in seq_len(n)) {
    definition$submit(
      command = c("sleep", "600"),
      memory_units = "mebibytes",
      memory = 128,
      cpus = 1,
      seconds_timeout = 600,
      tags = c("crew_aws_batch_1", "crew_aws_batch_2"),
      propagate_tags = TRUE
    )
  }
  while (nrow(monitor$active()) < n) {
    message(nrow(monitor$active()))
    Sys.sleep(1)
  }
  monitor$terminate(all = TRUE, verbose = TRUE)
  while (nrow(monitor$active()) > 0L) {
    message(paste(monitor$active()$status, collapse = " "))
    Sys.sleep(5)
  }
  expect_equal(nrow(monitor$active()), 0L)
})
