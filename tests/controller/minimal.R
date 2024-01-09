test_that("minimal workload", {
  definition <- "crew-aws-batch"
  queue <- "crew-aws-batch"
  region <- "us-east-1"
  monitor <- crew_monitor_aws_batch(
    job_definition = definition,
    job_queue = queue,
    region = region
  )
  for (processes in list(NULL, 1L)) {
    message("Testing a controller.")
    controller <- crew_controller_aws_batch(
      name = "my_workflow",
      workers = 1L,
      seconds_launch = 1800,
      seconds_idle = 300,
      processes = processes,
      aws_batch_job_definition = definition,
      aws_batch_job_queue = queue
    )
    controller$start()
    on.exit(controller$terminate())
    controller$push(
      name = "do work",
      command = as.character(Sys.info()["nodename"])
    )
    controller$wait()
    id <- controller$launcher$workers$handle[[1L]]$data$jobId
    message("Waiting for active jobs to be listed as started.")
    crew::crew_retry(
      ~id %in% monitor$active()$id,
      seconds_interval = 1,
      seconds_timeout = 180
    )
    task <- controller$pop()
    expect_false(task$result[[1L]] == as.character(Sys.info()["nodename"]))
    controller$launcher$terminate()
    message("Waiting for active jobs to terminate.")
    crew::crew_retry(
      ~!(id %in% monitor$active()$id),
      seconds_interval = 1,
      seconds_timeout = 180
    )
    controller$terminate()
  }
})
