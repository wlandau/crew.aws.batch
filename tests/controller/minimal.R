library(crew.aws.batch)
library(testthat)
for (processes in list(NULL, 1L)) {
  controller <- crew_controller_aws_batch(
    name = "my_workflow",
    workers = 1L,
    seconds_launch = 1800,
    seconds_idle = 300,
    processes = processes,
    aws_batch_job_definition = "crew-aws-batch",
    aws_batch_job_queue = "crew-aws-batch"
  )
  controller$start()
  controller$push( # Should see a job submission message.
    name = "do work",
    command = as.character(Sys.info()["nodename"])
  )
  controller$wait()
  task <- controller$pop()
  expect_false(task$result[[1L]] == as.character(Sys.info()["nodename"]))
  controller$launcher$terminate() # Should see a job deletion message.
  Sys.sleep(5L)
  controller$terminate()
}
