test_that("Manage job definitions", {
  x <- crew_definition_aws_batch(
    job_definition = "crew-aws-batch-test",
    job_queue = "crew-aws-batch-job-queue",
    region = "us-east-2"
  )
  revisions <- integer(0L)
  for (index in seq_len(2L)) {
    out <- x$register(
      image = "alpine:latest",
      platform_capabilities = "EC2",
      memory_units = "gigabytes",
      memory = 1,
      cpus = 1,
      seconds_timeout = 600,
      scheduling_priority = 3,
      tags = c("crew_aws_batch_1", "crew_aws_batch_2"),
      propagate_tags = TRUE
    )
    revisions <- c(revisions, out$revision)
  }
  expect_equal(nrow(out), 1L)
  expect_equal(out$name, x$job_definition)
  out <- x$describe()
  expect_gt(nrow(out), 1L)
  expect_equal(unique(out$name), x$job_definition)
  out <- x$describe(revision = max(revisions))
  expect_equal(nrow(out), 1L)
  expect_equal(out$name, x$job_definition)
  expect_equal(out$status, "active")
  expect_equal(out$revision, max(revisions))
  x$deregister()
  out <- x$describe(revision = max(revisions))
  expect_equal(out$revision, max(revisions))
  expect_equal(out$status, "inactive")
  x$deregister(revision = min(revisions))
  out <- x$describe(revision = min(revisions))
  expect_equal(out$revision, min(revisions))
  expect_equal(out$status, "inactive")
})

test_that("submit a job", {
  x <- crew_definition_aws_batch(
    job_definition = "crew-aws-batch-test",
    job_queue = "crew-aws-batch-job-queue",
    region = "us-east-2"
  )
  x$register(
    image = "alpine:latest",
    platform_capabilities = "EC2",
    memory_units = "mebibytes",
    memory = 128,
    cpus = 1,
    seconds_timeout = 60,
    tags = c("crew_aws_batch_1", "crew_aws_batch_2"),
    propagate_tags = TRUE
  )
  on.exit(x$deregister())
  job <- x$submit(
    command = c("sleep", "1"),
    memory_units = "mebibytes",
    memory = 500,
    cpus = 1,
    seconds_timeout = 60,
    tags = c("crew_aws_batch_1", "crew_aws_batch_2"),
    propagate_tags = TRUE
  )
  expect_true(tibble::is_tibble(job))
  expect_gt(nrow(job), 0L)
  expect_true(all(c("name", "id", "arn") %in% colnames(job)))
})
