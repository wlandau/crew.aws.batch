library(crew.aws.batch)
x <- crew_aws_batch_job_definition()
x$register(
  image = "alpine:latest",
  platform_capabilities = "EC2",
  memory_units = "gigabytes",
  memory = 1,
  cpus = 1,
  gpus = 0,
  seconds_timeout = 600,
  scheduling_priority = 3,
  tags = c("crew_aws_batch_1", "crew_aws_batch_2"),
  propagate_tags = TRUE
)
