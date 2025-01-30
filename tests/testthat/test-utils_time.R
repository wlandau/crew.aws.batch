test_that("as_timestamp()", {
  expect_true(anyNA(as_timestamp(numeric(0L))))
  expect_s3_class(as_timestamp(1000), "POSIXct")
})
