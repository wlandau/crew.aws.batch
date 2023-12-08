library(crew.aws.batch)
library(testthat)
x <- crew_aws_batch_monitor(
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
x$deregister()
