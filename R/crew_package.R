#' @title crew.aws.batch: a crew launcher plugin for AWS Batch
#' @name crew.aws.batch-package
#' @docType package
#' @family help
#' @description In computationally demanding analysis projects,
#'   statisticians and data scientists asynchronously
#'   deploy long-running tasks to distributed systems,
#'   ranging from traditional clusters to cloud services.
#'   The `crew.aws.batch` package extends the
#'   [`mirai`](https://github.com/shikokuchuo/mirai)-powered
#'   [`crew`](https://wlandau.github.io) package with worker
#'   launcher plugins for AWS Batch.
#'   Inspiration also comes from packages
#'   [`mirai`](https://github.com/shikokuchuo/mirai),
#'   [`future`](https://future.futureverse.org/),
#'   [`rrq`](https://mrc-ide.github.io/rrq/),
#'   [`clustermq`](https://mschubert.github.io/clustermq/),
#'   and [`batchtools`](https://mllg.github.io/batchtools/).
#' @importFrom crew crew_assert crew_class_launcher crew_deprecate
#'   crew_launcher crew_random_name crew_tls
#' @importFrom paws.common get_config paginate
#' @importFrom paws.compute batch
#' @importFrom paws.management cloudwatchlogs
#' @importFrom R6 R6Class
#' @importFrom rlang is_installed
#' @importFrom tibble tibble
#' @importFrom utils globalVariables
NULL

utils::globalVariables(".")
