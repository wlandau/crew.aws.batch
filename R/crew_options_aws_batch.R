#' @title AWS Batch options
#' @export
#' @keywords plugin_aws_batch
#' @description Options for the AWS Batch controller.
#' @return A classed list of options for the controller.
#' @section Retryable options:
#'   Arguments `cpus`, `gpus`, and `memory` are retryable options.
#'   Each of these arguments be a vector where each successive element is
#'   used during a retry if the worker previously exited without
#'   completing all its assigned tasks.
#'   The last element of the vector is used if there are more retries than
#'   the length of the vector.
#'   Control the number of allowable retries with `crashes_error`
#'   argument of the controller.
#' @param job_definition Character of length 1, name of the AWS
#'   Batch job definition to use. There is no default for this argument,
#'   and a job definition must be created prior to running the controller.
#'   Please see <https://docs.aws.amazon.com/batch/> for details.
#'
#'   To create a job definition, you will need to create a Docker-compatible
#'   image which can run R and `crew`. You may which to inherit
#'   from the images at <https://github.com/rocker-org/rocker-versioned2>.
#' @param job_queue Character of length 1, name of the AWS
#'   Batch job queue to use. There is no default for this argument,
#'   and a job queue must be created prior to running the controller.
#'   Please see <https://docs.aws.amazon.com/batch/> for details.
#' @param cpus Positive numeric vector, usually with a single element.
#'   Supply a vector to make `cpus` a retryable option
#'   (see the "Retryable options" section for details).
#'
#'   `cpus` is the number of virtual CPUs to request per job. Can be `NULL`
#'   to go with the defaults in the job definition. Ignored if
#'   `container_overrides` is not `NULL`.
#' @param gpus Positive numeric vector, usually a single element.
#'   Supply a vector to make `gpus` a retryable option
#'   (see the "Retryable options" section for details).
#'
#'   `gpus` is the number of GPUs to request per job. Can be `NULL`
#'   to go with the defaults in the job definition. Ignored if
#'   `container_overrides` is not `NULL`.
#' @param memory Positive numeric vector number, usually with a single
#'   element.
#'   Supply a vector to make `memory` a retryable option
#'   (see the "Retryable options" section for details).
#'
#'   `memory` is the amount of random access memory (RAM) to request per job.
#'   Choose the units of memory with the `memory_units` argument.
#'   Fargate instances can only be certain discrete values of mebibytes,
#'   so please choose `memory_units = "mebibytes"` in that case.
#'   The `memory` argument can be `NULL`
#'   to go with the defaults in the job definition. Ignored if
#'   `container_overrides` is not `NULL`.
#' @param memory_units Character string, units of memory of the `memory`
#'   argument. Can be `"gigabytes"` or `"mebibytes"`.
#'   Fargate instances can only be certain discrete values of mebibytes,
#'   so please choose `memory_units = "mebibytes"` in that case.
#' @param config Named list, `config` argument of
#'   `paws.compute::batch()` with optional configuration details.
#' @param credentials Named list. `credentials` argument of
#'   `paws.compute::batch()` with optional credentials (if not already
#'   provided through environment variables such as `AWS_ACCESS_KEY_ID`).
#' @param endpoint Character of length 1. `endpoint`
#'   argument of `paws.compute::batch()` with the endpoint to send HTTP
#'   requests.
#' @param region Character of length 1. `region` argument of
#'   `paws.compute::batch()` with an AWS region string such as `"us-east-2"`.
#' @param share_identifier `NULL` or character of length 1.
#'   For details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param scheduling_priority_override `NULL` or integer of length 1.
#'   For details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param parameters `NULL` or a nonempty list.
#'   For details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param container_overrides `NULL` or a nonempty named list of
#'   fields to override
#'   in the container specified in the job definition. Any overrides for the
#'   `command` field are ignored because `crew.aws.batch` needs to override
#'   the command to run the `crew` worker.
#'   For more details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param node_overrides `NULL` or a nonempty named list.
#'   For more details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param retry_strategy `NULL` or a nonempty named list.
#'   For more details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param propagate_tags `NULL` or a logical of length 1.
#'   For more details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param timeout `NULL` or a nonempty named list.
#'   For more details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param tags `NULL` or a nonempty named list.
#'   For more details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param eks_properties_override `NULL` or a nonempty named list.
#'   For more details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param verbose `TRUE` to print informative console messages, `FALSE`
#'   otherwise.
crew_options_aws_batch <- function(
  job_definition = "example",
  job_queue = "example",
  cpus = NULL,
  gpus = NULL,
  memory = NULL,
  memory_units = "gigabytes",
  config = list(),
  credentials = list(),
  endpoint = NULL,
  region = NULL,
  share_identifier = NULL,
  scheduling_priority_override = NULL,
  parameters = NULL,
  container_overrides = NULL,
  node_overrides = NULL,
  retry_strategy = NULL,
  propagate_tags = NULL,
  timeout = NULL,
  tags = NULL,
  eks_properties_override = NULL,
  verbose = FALSE
) {
  crew::crew_assert(
    job_definition,
    is.character(.),
    length(.) == 1L,
    !anyNA(.),
    nzchar(.),
    message = "job_definition must be a valid nonempty character string"
  )
  crew::crew_assert(
    job_queue,
    is.character(.),
    length(.) == 1L,
    !anyNA(.),
    nzchar(.),
    message = "job_queue must be a valid nonempty character string"
  )
  crew::crew_assert(
    memory_units,
    is.character(.),
    length(.) == 1L,
    !anyNA(.),
    nzchar(.),
    . %in% c("gigabytes", "mebibytes"),
    message = "memory_units must be \"gigabytes\" or \"mebibytes\""
  )
  crew::crew_assert(
    cpus %|||% 1,
    is.numeric(.),
    length(.) >= 1L,
    is.finite(.),
    . > 0,
    message = "cpus must be NULL or a numeric vector"
  )
  crew::crew_assert(
    gpus %|||% 1,
    is.numeric(.),
    length(.) >= 1L,
    is.finite(.),
    . > 0,
    message = "gpus must be NULL or a numeric vector"
  )
  crew::crew_assert(
    memory %|||% 0,
    is.numeric(.),
    length(.) >= 1L,
    is.finite(.),
    . >= 0,
    message = "memory must be NULL or a numeric vector"
  )
  crew::crew_assert(
    verbose,
    isTRUE(.) || isFALSE(.),
    message = "verbose must be TRUE or FALSE"
  )
  container_overrides <- container_overrides %|||% make_container_overrides(
    cpus = cpus,
    gpus = gpus,
    memory = memory,
    memory_units = memory_units
  )
  structure(
    list(
      job_definition = job_definition,
      job_queue = job_queue,
      config = config,
      credentials = credentials,
      endpoint = endpoint,
      region = region,
      share_identifier = share_identifier,
      scheduling_priority_override = scheduling_priority_override,
      parameters = parameters,
      container_overrides = container_overrides,
      node_overrides = node_overrides,
      retry_strategy = retry_strategy,
      propagate_tags = propagate_tags,
      timeout = timeout,
      tags = tags,
      eks_properties_override = eks_properties_override,
      verbose = verbose
    ),
    class = c("crew_options_aws_batch", "crew_options")
  )
}

make_container_overrides <- function(
  cpus = cpus,
  gpus = gpus,
  memory = memory,
  memory_units = memory_units
) {
  if (!is.null(memory) && identical(memory_units, "gigabytes")) {
    memory <- memory * ((5L ^ 9L) / (2L ^ 11L))
  }
  resources <- list()
  if (!is.null(memory)) {
    memory <- as.character(round(memory))
    resources$memory <- list(value = memory, type = "MEMORY")
  }
  if (!is.null(cpus)) {
    resources$cpus <- list(value = as.character(cpus), type = "VCPU")
  }
  if (!is.null(gpus)) {
    resources$gpus <- list(value = as.character(gpus), type = "GPU")
  }
  out <- list()
  if (length(resources)) {
    out$resourceRequirements <- resources
  }
  out
}
