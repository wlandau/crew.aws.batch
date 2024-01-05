# Must be tested interactively: tests/interactive/test-utils_progress.R
# nocov start
progress_init <- function(verbose, total) {
  if (!verbose || !interactive() || total < 2L) {
    return(NULL)
  }
  parent <- parent.frame()
  progress <- new.env(parent = parent)
  cli::cli_progress_bar(total = total, .envir = progress)
  progress
}

progress_update <- function(progress) {
  if (is.null(progress)) {
    return(NULL)
  }
  cli::cli_progress_update(.envir = progress)
}

progress_terminate <- function(progress) {
  if (is.null(progress)) {
    return(NULL)
  }
  cli::cli_progress_done(.envir = progress)
}
# nocov end
