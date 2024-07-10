#' @title Create an AWS Batch launcher object.
#' @export
#' @family plugin_aws_batch
#' @description Create an `R6` AWS Batch launcher object.
#' @inheritParams crew::crew_launcher
#' @section IAM policies:
#'   In order for the AWS Batch `crew` plugin to function properly, your IAM
#'   policy needs permission to perform the `SubmitJob` and `TerminateJob`
#'   AWS Batch API calls. For more information on AWS policies and permissions,
#'   please visit
#'   <https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html>.
#' @section AWS arguments:
#'   The AWS Batch controller and launcher accept many arguments
#'   which start with `"aws_batch_"`. These arguments are AWS-Batch-specific
#'   parameters forwarded directly to the `submit_job()` method for
#'   the Batch client in the `paws.compute` R package
#'
#'   For a full description
#'   of each argument, including its meaning and format, please visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/>. The upstream API
#'   documentation is at
#'   <https://docs.aws.amazon.com/batch/latest/APIReference/API_SubmitJob.html>
#'   and the analogous CLI documentation is at
#'   <https://docs.aws.amazon.com/cli/latest/reference/batch/submit-job.html>.
#'
#'   The actual argument names may vary slightly, depending
#'   on which : for example, the `aws_batch_job_definition` argument of
#'   the `crew` AWS Batch launcher/controller corresponds to the
#'   `jobDefinition` argument of the web API and
#'   `paws.compute::batch()$submit_job()`, and both correspond to the
#'   `--job-definition` argument of the CLI.
#' @section Verbosity:
#'   Control verbosity with the `paws.log_level` global option in R.
#'   Set to 0 for minimum verbosity and 3 for maximum verbosity.
#' @return An `R6` AWS Batch launcher object.
#' @param aws_batch_config Named list, `config` argument of
#'   `paws.compute::batch()` with optional configuration details.
#' @param aws_batch_credentials Named list. `credentials` argument of
#'   `paws.compute::batch()` with optional credentials (if not already
#'   provided through environment variables such as `AWS_ACCESS_KEY_ID`).
#' @param aws_batch_endpoint Character of length 1. `endpoint`
#'   argument of `paws.compute::batch()` with the endpoint to send HTTP
#'   requests.
#' @param aws_batch_region Character of length 1. `region` argument of
#'   `paws.compute::batch()` with an AWS region string such as `"us-east-2"`.
#' @param aws_batch_job_definition Character of length 1, name of the AWS
#'   Batch job definition to use. There is no default for this argument,
#'   and a job definition must be created prior to running the controller.
#'   Please see <https://docs.aws.amazon.com/batch/> for details.
#'
#'   To create a job definition, you will need to create a Docker-compatible
#'   image which can run R and `crew`. You may which to inherit
#'   from the images at <https://github.com/rocker-org/rocker-versioned2>.
#' @param aws_batch_job_queue Character of length 1, name of the AWS
#'   Batch job queue to use. There is no default for this argument,
#'   and a job queue must be created prior to running the controller.
#'   Please see <https://docs.aws.amazon.com/batch/> for details.
#' @param aws_batch_share_identifier `NULL` or character of length 1.
#'   For details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param aws_batch_scheduling_priority_override `NULL` or integer of length 1.
#'   For details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param aws_batch_parameters `NULL` or a nonempty list.
#'   For details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param aws_batch_container_overrides `NULL` or a nonempty named list of
#'   fields to override
#'   in the container specified in the job definition. Any overrides for the
#'   `command` field are ignored because `crew.aws.batch` needs to override
#'   the command to run the `crew` worker.
#'   For more details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param aws_batch_node_overrides `NULL` or a nonempty named list.
#'   For more details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param aws_batch_retry_strategy `NULL` or a nonempty named list.
#'   For more details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param aws_batch_propagate_tags `NULL` or a nonempty list.
#'   For more details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param aws_batch_timeout `NULL` or a nonempty named list.
#'   For more details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param aws_batch_tags `NULL` or a nonempty list.
#'   For more details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
#' @param aws_batch_eks_properties_override `NULL` or a nonempty named list.
#'   For more details, visit
#'   <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the
#'   "AWS arguments" sections of this help file.
crew_launcher_aws_batch <- function(
  name = NULL,
  seconds_interval = 0.5,
  seconds_timeout = 60,
  seconds_launch = 1800,
  seconds_idle = Inf,
  seconds_wall = Inf,
  tasks_max = Inf,
  tasks_timers = 0L,
  reset_globals = TRUE,
  reset_packages = FALSE,
  reset_options = FALSE,
  garbage_collection = FALSE,
  launch_max = 5L,
  tls = crew::crew_tls(mode = "automatic"),
  processes = NULL,
  aws_batch_config = list(),
  aws_batch_credentials = list(),
  aws_batch_endpoint = NULL,
  aws_batch_region = NULL,
  aws_batch_job_definition,
  aws_batch_job_queue,
  aws_batch_share_identifier = NULL,
  aws_batch_scheduling_priority_override = NULL,
  aws_batch_parameters = NULL,
  aws_batch_container_overrides = NULL,
  aws_batch_node_overrides = NULL,
  aws_batch_retry_strategy = NULL,
  aws_batch_propagate_tags = NULL,
  aws_batch_timeout = NULL,
  aws_batch_tags = NULL,
  aws_batch_eks_properties_override = NULL
) {
  name <- as.character(name %|||% crew::crew_random_name())
  launcher <- crew_class_launcher_aws_batch$new(
    name = name,
    seconds_interval = seconds_interval,
    seconds_timeout = seconds_timeout,
    seconds_launch = seconds_launch,
    seconds_idle = seconds_idle,
    seconds_wall = seconds_wall,
    tasks_max = tasks_max,
    tasks_timers = tasks_timers,
    reset_globals = reset_globals,
    reset_packages = reset_packages,
    reset_options = reset_options,
    garbage_collection = garbage_collection,
    launch_max = launch_max,
    tls = tls,
    processes = processes,
    aws_batch_config = aws_batch_config,
    aws_batch_credentials = aws_batch_credentials,
    aws_batch_endpoint = aws_batch_endpoint,
    aws_batch_region = aws_batch_region,
    aws_batch_job_definition = aws_batch_job_definition,
    aws_batch_job_queue = aws_batch_job_queue,
    aws_batch_share_identifier = aws_batch_share_identifier,
    aws_batch_scheduling_priority_override =
      aws_batch_scheduling_priority_override,
    aws_batch_parameters = aws_batch_parameters,
    aws_batch_container_overrides = aws_batch_container_overrides,
    aws_batch_node_overrides = aws_batch_node_overrides,
    aws_batch_retry_strategy = aws_batch_retry_strategy,
    aws_batch_propagate_tags = aws_batch_propagate_tags,
    aws_batch_timeout = aws_batch_timeout,
    aws_batch_tags = aws_batch_tags,
    aws_batch_eks_properties_override = aws_batch_eks_properties_override
  )
  launcher$validate()
  launcher
}

#' @title AWS Batch launcher class
#' @export
#' @family plugin_aws_batch
#' @description AWS Batch launcher `R6` class
#' @details See [crew_launcher_aws_batch()].
#' @inheritSection crew_launcher_aws_batch IAM policies
#' @inheritSection crew_launcher_aws_batch AWS arguments
#' @inheritSection crew_launcher_aws_batch Verbosity
crew_class_launcher_aws_batch <- R6::R6Class(
  classname = "crew_class_launcher_aws_batch",
  inherit = crew::crew_class_launcher,
  cloneable = FALSE,
  private = list(
    .aws_batch_config = NULL,
    .aws_batch_credentials = NULL,
    .aws_batch_endpoint = NULL,
    .aws_batch_region = NULL,
    .aws_batch_job_definition = NULL,
    .aws_batch_job_queue = NULL,
    .aws_batch_share_identifier = NULL,
    .aws_batch_scheduling_priority_override = NULL,
    .aws_batch_parameters = NULL,
    .aws_batch_container_overrides = NULL,
    .aws_batch_node_overrides = NULL,
    .aws_batch_retry_strategy = NULL,
    .aws_batch_propagate_tags = NULL,
    .aws_batch_timeout = NULL,
    .aws_batch_tags = NULL,
    .aws_batch_eks_properties_override = NULL,
    .args_client = function() {
      list(
        config = private$.aws_batch_config,
        credentials = private$.aws_batch_credentials,
        endpoint = private$.aws_batch_endpoint,
        region = private$.aws_batch_region
      )
    },
    .args_submit = function(call, name) {
      container_overrides <- as.list(private$.aws_batch_parameters)
      container_overrides$command <- list("R", "-e", call)
      list(
        jobName = name,
        jobQueue = private$.aws_batch_job_queue,
        shareIdentifier = private$.aws_batch_share_identifier,
        schedulingPriorityOverride =
          private$.aws_batch_scheduling_priority_override,
        jobDefinition = private$.aws_batch_job_definition,
        parameters = private$.aws_batch_parameters,
        containerOverrides = container_overrides,
        nodeOverrides = private$.aws_batch_node_overrides,
        retryStrategy = private$.aws_batch_retry_strategy,
        propagateTags = private$.aws_batch_propagate_tags,
        timeout = private$.aws_batch_timeout,
        tags = private$.aws_batch_tags,
        eksPropertiesOverride = private$.aws_batch_eks_properties_override
      )
    }
  ),
  active = list(
    #' @field aws_batch_config See [crew_launcher_aws_batch()].
    aws_batch_config = function() {
      .subset2(private, ".aws_batch_config")
    },
    #' @field aws_batch_credentials See [crew_launcher_aws_batch()].
    aws_batch_credentials = function() {
      .subset2(private, ".aws_batch_credentials")
    },
    #' @field aws_batch_endpoint See [crew_launcher_aws_batch()].
    aws_batch_endpoint = function() {
      .subset2(private, ".aws_batch_endpoint")
    },
    #' @field aws_batch_region See [crew_launcher_aws_batch()].
    aws_batch_region = function() {
      .subset2(private, ".aws_batch_region")
    },
    #' @field aws_batch_job_definition See [crew_launcher_aws_batch()].
    aws_batch_job_definition = function() {
      .subset2(private, ".aws_batch_job_definition")
    },
    #' @field aws_batch_job_queue See [crew_launcher_aws_batch()].
    aws_batch_job_queue = function() {
      .subset2(private, ".aws_batch_job_queue")
    },
    #' @field aws_batch_share_identifier See [crew_launcher_aws_batch()].
    aws_batch_share_identifier = function() {
      .subset2(private, ".aws_batch_share_identifier")
    },
    #' @field aws_batch_scheduling_priority_override
    #'   See [crew_launcher_aws_batch()].
    aws_batch_scheduling_priority_override = function() {
      .subset2(private, ".aws_batch_scheduling_priority_override")
    },
    #' @field aws_batch_parameters See [crew_launcher_aws_batch()].
    aws_batch_parameters = function() {
      .subset2(private, ".aws_batch_parameters")
    },
    #' @field aws_batch_container_overrides See [crew_launcher_aws_batch()].
    aws_batch_container_overrides = function() {
      .subset2(private, ".aws_batch_container_overrides")
    },
    #' @field aws_batch_node_overrides See [crew_launcher_aws_batch()].
    aws_batch_node_overrides = function() {
      .subset2(private, ".aws_batch_node_overrides")
    },
    #' @field aws_batch_retry_strategy See [crew_launcher_aws_batch()].
    aws_batch_retry_strategy = function() {
      .subset2(private, ".aws_batch_retry_strategy")
    },
    #' @field aws_batch_propagate_tags See [crew_launcher_aws_batch()].
    aws_batch_propagate_tags = function() {
      .subset2(private, ".aws_batch_propagate_tags")
    },
    #' @field aws_batch_timeout See [crew_launcher_aws_batch()].
    aws_batch_timeout = function() {
      .subset2(private, ".aws_batch_timeout")
    },
    #' @field aws_batch_tags See [crew_launcher_aws_batch()].
    aws_batch_tags = function() {
      .subset2(private, ".aws_batch_tags")
    },
    #' @field aws_batch_eks_properties_override
    #'   See [crew_launcher_aws_batch()].
    aws_batch_eks_properties_override = function() {
      .subset2(private, ".aws_batch_eks_properties_override")
    }
  ),
  public = list(
    #' @description Abstract launcher constructor.
    #' @return An abstract launcher object.
    #' @param name See [crew_launcher_aws_batch()].
    #' @param seconds_interval See [crew_launcher_aws_batch()].
    #' @param seconds_timeout See [crew_launcher_aws_batch()].
    #' @param seconds_launch See [crew_launcher_aws_batch()].
    #' @param seconds_idle See [crew_launcher_aws_batch()].
    #' @param seconds_wall See [crew_launcher_aws_batch()].
    #' @param tasks_max See [crew_launcher_aws_batch()].
    #' @param tasks_timers See [crew_launcher_aws_batch()].
    #' @param reset_globals See [crew_launcher_aws_batch()].
    #' @param reset_packages See [crew_launcher_aws_batch()].
    #' @param reset_options See [crew_launcher_aws_batch()].
    #' @param garbage_collection See [crew_launcher_aws_batch()].
    #' @param launch_max See [crew_launcher_aws_batch()].
    #' @param tls See [crew_launcher_aws_batch()].
    #' @param processes See [crew_launcher_aws_batch()].
    #' @param aws_batch_config See [crew_launcher_aws_batch()].
    #' @param aws_batch_credentials See [crew_launcher_aws_batch()].
    #' @param aws_batch_endpoint See [crew_launcher_aws_batch()].
    #' @param aws_batch_region See [crew_launcher_aws_batch()].
    #' @param aws_batch_job_definition See [crew_launcher_aws_batch()].
    #' @param aws_batch_job_queue See [crew_launcher_aws_batch()].
    #' @param aws_batch_share_identifier See [crew_launcher_aws_batch()].
    #' @param aws_batch_scheduling_priority_override
    #'   See [crew_launcher_aws_batch()].
    #' @param aws_batch_parameters See [crew_launcher_aws_batch()].
    #' @param aws_batch_container_overrides See [crew_launcher_aws_batch()].
    #' @param aws_batch_node_overrides See [crew_launcher_aws_batch()].
    #' @param aws_batch_retry_strategy See [crew_launcher_aws_batch()].
    #' @param aws_batch_propagate_tags See [crew_launcher_aws_batch()].
    #' @param aws_batch_timeout See [crew_launcher_aws_batch()].
    #' @param aws_batch_tags See [crew_launcher_aws_batch()].
    #' @param aws_batch_eks_properties_override
    #'   See [crew_launcher_aws_batch()].
    initialize = function(
      name = NULL,
      seconds_interval = NULL,
      seconds_timeout = NULL,
      seconds_launch = NULL,
      seconds_idle = NULL,
      seconds_wall = NULL,
      tasks_max = NULL,
      tasks_timers = NULL,
      reset_globals = NULL,
      reset_packages = NULL,
      reset_options = NULL,
      garbage_collection = NULL,
      launch_max = NULL,
      tls = NULL,
      processes = NULL,
      aws_batch_config = NULL,
      aws_batch_credentials = NULL,
      aws_batch_endpoint = NULL,
      aws_batch_region = NULL,
      aws_batch_job_definition = NULL,
      aws_batch_job_queue = NULL,
      aws_batch_share_identifier = NULL,
      aws_batch_scheduling_priority_override = NULL,
      aws_batch_parameters = NULL,
      aws_batch_container_overrides = NULL,
      aws_batch_node_overrides = NULL,
      aws_batch_retry_strategy = NULL,
      aws_batch_propagate_tags = NULL,
      aws_batch_timeout = NULL,
      aws_batch_tags = NULL,
      aws_batch_eks_properties_override = NULL
    ) {
      super$initialize(
        name = name,
        seconds_interval = seconds_interval,
        seconds_timeout = seconds_timeout,
        seconds_launch = seconds_launch,
        seconds_idle = seconds_idle,
        seconds_wall = seconds_wall,
        tasks_max = tasks_max,
        tasks_timers = tasks_timers,
        reset_globals = reset_globals,
        reset_packages = reset_packages,
        reset_options = reset_options,
        garbage_collection = garbage_collection,
        launch_max = launch_max,
        tls = tls,
        processes = processes
      )
      private$.aws_batch_config <- aws_batch_config
      private$.aws_batch_credentials <- aws_batch_credentials
      private$.aws_batch_endpoint <- aws_batch_endpoint
      private$.aws_batch_region <- aws_batch_region
      private$.aws_batch_job_definition <- aws_batch_job_definition
      private$.aws_batch_job_queue <- aws_batch_job_queue
      private$.aws_batch_share_identifier <- aws_batch_share_identifier
      private$.aws_batch_scheduling_priority_override <-
        aws_batch_scheduling_priority_override
      private$.aws_batch_parameters <- aws_batch_parameters
      private$.aws_batch_parameters <- aws_batch_container_overrides
      private$.aws_batch_node_overrides <- aws_batch_node_overrides
      private$.aws_batch_retry_strategy <- aws_batch_retry_strategy
      private$.aws_batch_propagate_tags <- aws_batch_propagate_tags
      private$.aws_batch_timeout <- aws_batch_timeout
      private$.aws_batch_tags <- aws_batch_tags
      private$.aws_batch_eks_properties_override <-
        aws_batch_eks_properties_override
    },
    #' @description Validate the launcher.
    #' @return `NULL` (invisibly). Throws an error if a field is invalid.
    validate = function() {
      super$validate() # nolint
      for (field in c("aws_batch_config", "aws_batch_credentials")) {
        crew::crew_assert(
          self[[field]],
          is.list(.),
          message = paste(field, "must be a list")
        )
      }
      for (field in c("aws_batch_job_definition", "aws_batch_job_queue")) {
        crew::crew_assert(
          self[[field]],
          is.character(.),
          !anyNA(.),
          nzchar(.),
          length(.) == 1L,
          message = paste(
            field,
            "must be a nonempty character of length 1.",
            "AWS Batch job definitions and job queues must be created",
            "before the {crew.aws.batch} controller can work properly."
          )
        )
      }
      fields <- c(
        "aws_batch_endpoint",
        "aws_batch_region",
        "aws_batch_share_identifier"
      )
      for (field in fields) {
        crew::crew_assert(
          self[[field]] %|||% "x",
          is.character(.),
          !anyNA(.),
          nzchar(.),
          length(.) == 1L,
          message = paste(
            field,
            "must be NULL or a nonempty character of length 1."
          )
        )
      }
      crew::crew_assert(
        private$.aws_batch_scheduling_priority_override %|||% 1L,
        is.numeric(.),
        !anyNA(.),
        nzchar(.),
        length(.) == 1L,
        message = paste(
          "aws_batch_scheduling_priority_override must be NULL",
          "or a nonempty integer of length 1."
        )
      )
      fields <- c(
        "aws_batch_parameters",
        "aws_batch_container_overrides",
        "aws_batch_node_overrides",
        "aws_batch_retry_strategy",
        "aws_batch_propagate_tags",
        "aws_batch_timeout",
        "aws_batch_tags",
        "aws_batch_eks_properties_override"
      )
      for (field in fields) {
        crew::crew_assert(
          self[[field]] %|||% list("item"),
          length(.) > 0L,
          message = paste(field, "must be NULL or a nonempty list")
        )
      }
      invisible()
    },
    #' @description Launch a local process worker which will
    #'   dial into a socket.
    #' @details The `call` argument is R code that will run to
    #'   initiate the worker.
    #' @return A handle object to allow the termination of the worker
    #'   later on.
    #' @param call Character of length 1, a namespaced call to
    #'   [crew::crew_worker()]
    #'   which will run in the worker and accept tasks.
    #' @param name Character of length 1, an informative worker name.
    #' @param launcher Character of length 1, name of the launcher.
    #' @param worker Positive integer of length 1, index of the worker.
    #'   This worker index remains the same even when the current instance
    #'   of the worker exits and a new instance launches.
    #'   It is always between 1 and the maximum number of concurrent workers.
    #' @param instance Character of length 1 to uniquely identify
    #'   the current instance of the worker.
    launch_worker = function(call, name, launcher, worker, instance) {
      # Tested in tests/controller/persistent.R
      # nocov start
      self$async$eval(
        command = crew.aws.batch::crew_launcher_aws_batch_launch(
          args_client = args_client,
          args_submit = args_submit
        ),
        data = list(
          args_client = private$.args_client(),
          args_submit = private$.args_submit(call = call, name = name)
        )
      )
      # nocov end
    },
    #' @description Terminate a local process worker.
    #' @return `NULL` (invisibly).
    #' @param handle A process handle object previously
    #'   returned by `launch_worker()`.
    terminate_worker = function(handle) {
      # Tested in tests/controller/minimal.R
      # nocov start
      self$async$eval(
        crew.aws.batch::crew_launcher_aws_batch_terminate(
          args_client = args_client,
          job_id = job_id
        ),
        data = list(
          args_client = private$.args_client(),
          job_id = handle$data$jobId
        )
      )
      # nocov end
    }
  )
)

#' @title Submit an AWS Batch job.
#' @export
#' @keywords internal
#' @description Not a user-side function. For internal use only.
#' @details This utility is its own separate exported function specific to
#'   the launcher and not shared with the job definition or monitor classes.
#'   It generates the `paws.compute::batch()` client within itself
#'   instead of a method inside the class.
#'   This is all because it needs to run on a separate local worker process
#'   and it needs to accept exportable arguments.
#' @return HTTP response from submitting the job.
#' @param args_client Named list of arguments to `paws.compute::batch()`.
#' @param args_submit Named list of arguments to
#'   `paws.compute::batch()$submit_job()`.
crew_launcher_aws_batch_launch <- function(args_client, args_submit) {
  # Tested in tests/controller/persistent.R
  # nocov start
  client <- do.call(what = paws.compute::batch, args = args_client)
  do.call(what = client$submit_job, args = args_submit)
  # nocov end
}

#' @title Terminate an AWS Batch job.
#' @export
#' @keywords internal
#' @description Not a user-side function. For internal use only.
#' @details This utility is its own separate exported function specific to
#'   the launcher and not shared with the job definition or monitor classes.
#'   It generates the `paws.compute::batch()` client within itself
#'   instead of a method inside the class.
#'   This is all because it needs to run on a separate local worker process
#'   and it needs to accept exportable arguments.
#' @return HTTP response from submitting the job.
#' @param args_client Named list of arguments to `paws.compute::batch()`.
#' @param job_id Character of length 1, ID of the AWS Batch job to
#'   terminate.
crew_launcher_aws_batch_terminate <- function(args_client, job_id) {
  # nocov start
  # Tested in tests/controller/minimal.R
  client <- do.call(what = paws.compute::batch, args = args_client)
  client$terminate_job(
    jobId = job_id,
    reason = "terminated by crew controller"
  )
  # nocov end
}
