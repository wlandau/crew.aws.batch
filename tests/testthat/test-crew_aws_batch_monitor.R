test_that("crew_aws_batch_monitor()", {
  out <- crew_aws_batch_monitor(
    job_queue = "job_queue_name",
    job_definition = "job_definition_name",
    log_group = "/aws/batch/job",
    config = list(config = TRUE),
    credentials = list(credentials = TRUE),
    endpoint = "endpoint_url",
    region = "us-east-2"
  )
  expect_silent(out$validate())
  expect_equal(out$job_queue, "job_queue_name")
  expect_equal(out$job_definition, "job_definition_name")
  expect_equal(out$log_group, "/aws/batch/job")
  expect_equal(out$config, list(config = TRUE))
  expect_equal(out$credentials, list(credentials = TRUE))
  expect_equal(out$endpoint, "endpoint_url")
  expect_equal(out$region, "us-east-2")
})

test_that("crew_aws_batch_monitor() private$.register_args()", {
  skip_on_cran()
  x <- crew_aws_batch_monitor(
    job_definition = "job-definition-name",
    job_queue = "crew-aws-batch-job-queue",
    region = "us-east-2"
  )
  out <- x$.__enclos_env__$private$.register_args(
    image = "alpine:latest",
    platform_capabilities = "EC2",
    memory_units = "gigabytes",
    memory = 1,
    cpus = 1,
    gpus = 1,
    seconds_timeout = 600,
    scheduling_priority = 3,
    tags = c("crew_aws_batch_1", "crew_aws_batch_2"),
    propagate_tags = TRUE,
    job_role_arn = "job_role_arn_id",
    execution_role_arn = "execution_role_arn_id"
  )
  exp <- list(
    jobDefinitionName = "job-definition-name",
    type = "container",
    schedulingPriority = 3,
    propagateTags = TRUE,
    platformCapabilities = "EC2",
    timeout = list(attemptDurationSeconds = 600),
    containerProperties = list(
      image = "alpine:latest",
      resourceRequirements = list(
        memory = list(value = "954", type = "MEMORY"),
        cpus = list(
          value = "1",
          type = "VCPU"
        ),
        gpus = list(
          value = "1",
          type = "GPU"
        )
      ),
      logConfiguration = list(
        logDriver = "awslogs",
        options = list(
          "awslogs-group" = "/aws/batch/job",
          "awslogs-region" = "us-east-2",
          "awslogs-stream-prefix" = "job-definition-name"
        )
      )
    )
  )
  expect_equal(out, exp)
})

test_that("crew_aws_batch_monitor() private$.client()", {
  skip_on_cran()
  x <- crew_aws_batch_monitor(job_queue = "x")
  out <- x$.__enclos_env__$private$.client()
  expect_true(is.function(out$list_jobs))
})
