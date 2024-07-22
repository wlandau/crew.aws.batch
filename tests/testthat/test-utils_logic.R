test_that("%||%", {
  expect_equal("a" %||% "b", "a")
  expect_equal(list() %||% "b", "b")
  expect_equal(NULL %||% "b", "b")
})

test_that("%|||%", {
  expect_equal("a" %|||% "b", "a")
  expect_equal(list() %|||% "b", list())
  expect_equal(NULL %|||% "b", "b")
})

test_that("%|||chr%", {
  expect_equal("a" %|||chr% "b", "a")
  expect_equal("" %|||chr% "b", "b")
  expect_equal(list() %|||chr% "b", list())
  expect_equal(NULL %|||chr% "b", NULL)
})


test_that("if_any()", {
  expect_equal(if_any(TRUE, "a", "b"), "a")
  expect_equal(if_any(FALSE, "a", "b"), "b")
})

test_that("non_null()", {
  x <- list(a = 1, b = NULL, c = 3)
  expect_equal(length(x), 3L)
  out <- non_null(x)
  expect_equal(length(out), 2L)
  expect_equal(names(out), c("a", "c"))
})
