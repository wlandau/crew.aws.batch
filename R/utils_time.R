as_timestamp <- function(x) {
  as.POSIXct(if_any(length(x) > 0L, x / 1000, NA_real_))
}
