test_that("persistent worker workload", {
  definition <- "crew-aws-batch"
  queue <- "crew-aws-batch"
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
    n <- 200
    for (index in seq_len(n)) {
      name <- paste0("task_", index)
      controller$push(
        name = name,
        command = as.character(Sys.info()["nodename"])
      )
      message(paste("push", name))
    }
    results <- list()
    message("Waiting for results.")
    while (length(results) < n) {
      out <- controller$pop()
      if (!is.null(out)) {
        results[[length(results) + 1L]] <- out
        message(paste("done", out$name, out$result[[1]]))
      }
    }
    controller$terminate()
    results <- tibble::as_tibble(do.call(rbind, results))
    results$result <- as.character(results$result)
    expect_equal(length(unique(results$result)), 1L)
    expect_false(anyNA(results$result))
    expect_false(any(results$result == as.character(Sys.info()["nodename"])))
    expect_equal(results$error, rep(NA_character_, n))
    expect_equal(
      sort(paste0("task_", seq_len(n))),
      sort(unique(results$name))
    )
  }
})
