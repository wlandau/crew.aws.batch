test_that("Should see a progress bar.", {
  progress <- progress_init(verbose = TRUE, total = 10)
  for (index in seq_len(10)) {
    Sys.sleep(0.5)
    progress_update(progress)
  }
  Sys.sleep(0.5)
  progress_terminate(progress)
  expect_true(TRUE)
})

test_that("Should not see a progress bar.", {
  progress <- progress_init(verbose = FALSE, total = 10)
  for (index in seq_len(10)) {
    Sys.sleep(0.5)
    progress_update(progress)
  }
  Sys.sleep(0.5)
  progress_terminate(progress)
  expect_true(TRUE)
})
