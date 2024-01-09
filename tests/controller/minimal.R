test_that("minimal workload", {
  definition <- "crew-aws-batch"
  queue <- "crew-aws-batch"
  monitor <- crew_monitor_aws_batch(
    job_definition = definition,
    job_queue = queue
  )
  for (processes in list(NULL, 1L)) {
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
    task <- controller$pop()
    expect_false(task$result[[1L]] == as.character(Sys.info()["nodename"]))
    controller$launcher$terminate()
    Sys.sleep(5L)
  }
})
