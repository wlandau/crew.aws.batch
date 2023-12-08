library(crew.aws.batch)
library(testthat)
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
out <- x$jobs()
expect_true(tibble::is_tibble(x$submitted()))
expect_true(tibble::is_tibble(x$active()))
expect_true(tibble::is_tibble(x$inactive()))
expect_true(tibble::is_tibble(x$pending()))
expect_true(tibble::is_tibble(x$runnable()))
expect_true(tibble::is_tibble(x$succeeded()))
expect_true(tibble::is_tibble(x$failed()))
expect_true(nrow(out) > 0L)
expect_true(job$name %in% out$name)
expect_true(job$id %in% out$id)
expect_true(job$arn %in% out$arn)
info <- out[out$name == job$name, ]
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
  out <- x$jobs()
  info <- out[out$name == job$name, ]
  attempts <- attempts + 1L
  if (attempts > 20L) {
    stop("job did not terminate")
  }
  Sys.sleep(5)
}
expect_true(info$status %in% c("succeeded", "failed"))
expect_equal(info$reason, good_reason)
x$deregister()
