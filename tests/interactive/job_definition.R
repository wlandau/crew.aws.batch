library(crew.aws.batch)
x <- crew_aws_batch_job_definition()
x$register(
  image = "alpine:latest",
  platform_capabilities = "EC2",
  
)