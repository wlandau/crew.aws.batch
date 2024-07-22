`%||%` <- function(x, y) {
  if (length(x) > 0L) {
    x
  } else {
    y
  }
}

`%|||%` <- function(x, y) {
  if (is.null(x)) {
    y
  } else {
    x
  }
}

`%|||chr%` <- function(x, y) {
  if (identical(unname(x), "")) {
    y
  } else {
    x
  }
}

if_any <- function(condition, true, false) {
  if (any(condition)) {
    true
  } else {
    false
  }
}

non_null <- function(x) {
  Filter(f = function(x) !is.null(x), x = x)
}
