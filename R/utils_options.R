crew_options_slice <- function(options, index) {
  for (name in c("cpus", "gpus", "memory")) {
    options$container_overrides$resourceRequirements[[name]]$value <-
      slice_bounded(
        options$container_overrides$resourceRequirements[[name]]$value,
        index
      )
  }
  options
}

slice_bounded <- function(x, index) {
  x[min(index, length(x))]
}
