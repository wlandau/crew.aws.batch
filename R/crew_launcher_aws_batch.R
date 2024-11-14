#' @title Create an AWS Batch launcher object.
#' @export
#' @family plugin_aws_batch
#' @description Create an `R6` AWS Batch launcher object.
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
#' @inheritParams crew::crew_launcher
#' @param options_aws_batch List of options from [crew_options_aws_batch()].
#'   The job definition and job queue must be specified in
#'   [crew_options_aws_batch()]. [crew_options_aws_batch()] also allows
#'   you to request vCPUs, GPUs, and memory for the jobs.
#' @param aws_batch_config Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_credentials Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_endpoint Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_region Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_job_definition Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_job_queue Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_share_identifier Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_scheduling_priority_override Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_parameters Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_container_overrides Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_node_overrides Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_retry_strategy Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_propagate_tags Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_timeout Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_tags Deprecated.
#'   Use `options_aws_batch` instead.
#' @param aws_batch_eks_properties_override Deprecated.
#'   Use `options_aws_batch` instead.
crew_launcher_aws_batch <- function(
  name = NULL,
  seconds_interval = 0.5,
  seconds_timeout = 60,
  seconds_launch = 1800,
  seconds_idle = 300,
  seconds_wall = Inf,
  tasks_max = Inf,
  tasks_timers = 0L,
  reset_globals = TRUE,
  reset_packages = FALSE,
  reset_options = FALSE,
  garbage_collection = FALSE,
  crashes_error = 5L,
  tls = crew::crew_tls(mode = "automatic"),
  processes = NULL,
  r_arguments = c("--no-save", "--no-restore"),
  options_metrics = crew::crew_options_metrics(),
  options_aws_batch = crew.aws.batch::crew_options_aws_batch(),
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
  name <- as.character(name %|||% crew::crew_random_name())
  args <- match.call()
  crew::crew_assert(
    options_aws_batch,
    inherits(., c("crew_options_aws_batch", "crew_options"))
  )
  deprecated <- grep("^aws_", names(formals()), value = TRUE)
  for (arg in deprecated) {
    value <- get(arg)
    crew::crew_deprecate(
      name = arg,
      date = "2024-10-09",
      version = "0.0.6.9008",
      alternative = "options_aws_batch argument",
      value = value
    )
    field <- gsub("^aws_batch_", "", arg)
    options_aws_batch[[field]] <- value %|||% options_aws_batch[[field]]
  }
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
    crashes_error = crashes_error,
    tls = tls,
    processes = processes,
    r_arguments = r_arguments,
    options_metrics = options_metrics,
    options_aws_batch = options_aws_batch
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
    .options_aws_batch = NULL,
    .args_client = function() {
      list(
        config = private$.options_aws_batch$config,
        credentials = private$.options_aws_batch$credentials,
        endpoint = private$.options_aws_batch$endpoint,
        region = private$.options_aws_batch$region
      )
    },
    .args_submit = function(call, name, attempt) {
      if (private$.options_aws_batch$verbose) {
        crew_message(
          "Launching worker ",
          name,
          " attempt ",
          attempt,
          " of ",
          private$.crashes_error
        )
      }
      options <- crew_options_slice(private$.options_aws_batch, attempt)
      container_overrides <- as.list(options$container_overrides)
      container_overrides$command <- list("Rscript", "-e", call)
      out <- list(
        jobName = crew.aws.batch::crew_aws_batch_job_name(name),
        jobQueue = options$job_queue,
        shareIdentifier = options$share_identifier,
        schedulingPriorityOverride = options$scheduling_priority_override,
        jobDefinition = options$job_definition,
        parameters = options$parameters,
        containerOverrides = container_overrides,
        nodeOverrides = options$node_overrides,
        retryStrategy = options$retry_strategy,
        propagateTags = options$propagate_tags,
        timeout = options$timeout,
        tags = options$tags,
        eksPropertiesOverride = options$eks_properties_override
      )
      non_null(out)
    }
  ),
  active = list(
    #' @field options_aws_batch See [crew_launcher_aws_batch()].
    options_aws_batch = function() {
      .subset2(private, ".options_aws_batch")
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
    #' @param crashes_error See [crew_launcher_aws_batch()].
    #' @param tls See [crew_launcher_aws_batch()].
    #' @param processes See [crew_launcher_aws_batch()].
    #' @param r_arguments See [crew_launcher_aws_batch()].
    #' @param options_metrics See [crew_launcher_aws_batch()].
    #' @param options_aws_batch See [crew_launcher_aws_batch()].
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
      crashes_error = NULL,
      tls = NULL,
      processes = NULL,
      r_arguments = NULL,
      options_metrics = NULL,
      options_aws_batch = NULL
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
        crashes_error = crashes_error,
        tls = tls,
        processes = processes,
        r_arguments = r_arguments,
        options_metrics = options_metrics
      )
      private$.options_aws_batch <- options_aws_batch
    },
    #' @description Validate the launcher.
    #' @return `NULL` (invisibly). Throws an error if a field is invalid.
    validate = function() {
      super$validate() # nolint
      crew::crew_assert(
        private$.options_aws_batch,
        inherits(., c("crew_options_aws_batch", "crew_options"))
      )
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
          args_submit = private$.args_submit(
            call = call,
            name = name,
            attempt = self$crashes(index = worker) + 1L
          )
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
  client$cancel_job(
    jobId = job_id,
    reason = "cancelled by crew controller"
  )
  client$terminate_job(
    jobId = job_id,
    reason = "terminated by crew controller"
  )
  # nocov end
}

#' @title Terminate an AWS Batch job.
#' @export
#' @keywords internal
#' @description Not a user-side function. For internal use only.
#' @return Character string, a valid AWS Batch job name.
#' @param name Character string, an AWS Batch job name, possibly invalid.
crew_aws_batch_job_name <- function(name) {
  name <- gsub(pattern = "[^a-zA-Z0-9_-]", replacement = "_", x = name)
  if (!any(grepl("^[a-zA-Z0-9]", name))) {
    name <- paste0("x", name)
  }
  substr(x = name, start = 1L, stop = 128L)
}
