#' @title Create an AWS Batch monitor object.
#' @export
#' @family monitor
#' @description Create an `R6` object to manage AWS Batch jobs and
#'   job definitions.
#' @param job_queue Character of length 1, name of the AWS Batch
#'   job queue.
#' @param job_definition Character of length 1, name of the AWS Batch
#'   job definition.
#' @param log_group Character of length 1,
#'   AWS Batch CloudWatch log group to get job logs.
#'   The default log group is often "/aws/batch/job", but not always.
#'   It is not easy to get the log group of an active job or job
#'   definition, so if you have a non-default log group and you do not
#'   know its name, please consult your system administrator.
#' @param config Optional named list, `config` argument of
#'   `paws.compute::batch()` with optional configuration details.
#' @param credentials Optional named list. `credentials` argument of
#'   `paws.compute::batch()` with optional credentials (if not already
#'   provided through environment variables such as `AWS_ACCESS_KEY_ID`).
#' @param endpoint Optional character of length 1. `endpoint`
#'   argument of `paws.compute::batch()` with the endpoint to send HTTP
#'   requests.
#' @param region Character of length 1. `region` argument of
#'   `paws.compute::batch()` with an AWS region string such as `"us-east-2"`.
#'   Serves as the region for both AWS Batch and CloudWatch. Tries to
#'   default to `paws.common::get_config()$region`, then to
#'   `Sys.getenv("AWS_REGION")` if unsuccessful, then
#'   `Sys.getenv("AWS_REGION")`, then `Sys.getenv("AWS_DEFAULT_REGION")`.
crew_aws_batch_monitor <- function(
  job_queue,
  job_definition = paste0(
    "crew-aws-batch-job-definition-",
    crew::crew_random_name()
  ),
  log_group = "/aws/batch/job",
  config = NULL,
  credentials = NULL,
  endpoint = NULL,
  region = NULL
) {
  region <- region %|||% paws.common::get_config()$region
  region <- region %|||chr% Sys.getenv("AWS_REGION", unset = "")
  region <- region %|||chr% Sys.getenv("AWS_DEFAULT_REGION", unset = "")
  out <- crew_class_aws_batch_monitor$new(
    job_queue = job_queue,
    job_definition = job_definition,
    log_group = log_group,
    config = config,
    credentials = credentials,
    endpoint = endpoint,
    region = region
  )
  out$validate()
  out
}

#' @title AWS Batch monitor class
#' @export
#' @family monitor
#' @description AWS Batch job definition `R6` class
#' @details See [crew_aws_batch_monitor()].
crew_class_aws_batch_monitor <- R6::R6Class(
  classname = "crew_class_aws_batch_monitor",
  cloneable = FALSE,
  private = list(
    .job_queue = NULL,
    .job_definition = NULL,
    .log_group = NULL,
    .config = NULL,
    .credentials = NULL,
    .endpoint = NULL,
    .region = NULL,
    .client = function() {
      paws.compute::batch(
        config = as.list(private$.config),
        credentials = as.list(private$.credentials),
        endpoint = private$.endpoint,
        region = private$.region
      )
    },
    .args_register = function(
      image,
      platform_capabilities,
      memory_units,
      memory,
      cpus,
      gpus,
      seconds_timeout,
      scheduling_priority,
      tags,
      propagate_tags,
      parameters,
      job_role_arn,
      execution_role_arn
    ) {
      crew::crew_assert(
        image,
        is.character(.),
        !anyNA(.),
        length(.) == 1L,
        nzchar(.),
        message = paste("invalid image path")
      )
      crew::crew_assert(
        unname(platform_capabilities),
        identical(., "EC2") || identical(., "FARGATE"),
        message = "platform_capabilities must be \"EC2\" or \"FARGATE\"."
      )
      crew::crew_assert(
        unname(memory_units),
        identical(., "gigabytes") || identical(., "mebibytes"),
        message = "memory_units must be \"gigabytes\" or \"mebibytes\"."
      )
      amounts <- list(
        memory = memory,
        cpus = cpus,
        gpus = gpus,
        seconds_timeout = seconds_timeout,
        scheduling_priority = scheduling_priority
      )
      for (name in names(amounts)) {
        crew::crew_assert(
          amounts[[name]] %|||% 1L,
          is.numeric(.),
          is.finite(.),
          . >= 0,
          message = paste(
            name,
            "must be NULL or positive numeric of length 1."
          )
        )
      }
      crew_assert(
        tags %|||% "x",
        is.character(.),
        !anyNA(.),
        nzchar(.),
        message = "'tags' must be a character vector or NULL."
      )
      crew_assert(
        parameters %|||% "x",
        is.character(.),
        !anyNA(.),
        nzchar(.),
        message = "'parameters' must be a character vector or NULL."
      )
      crew_assert(
        propagate_tags %|||% TRUE,
        isTRUE(.) || isFALSE(.),
        message = "propagate_tags must be NULL or TRUE or FALSE"
      )
      flags <- list(
        job_role_arn = job_role_arn,
        execution_role_arn = execution_role_arn
      )
      for (name in names(flags)) {
        crew_assert(
          flags[[name]] %|||% "x",
          is.character(.),
          !anyNA(.),
          nzchar(.),
          length(.) == 1L,
          message = paste(name, "must be NULL or a character of length 1.")
        )
      }
      if (identical(memory_units, "gigabytes")) {
        memory <- memory * ((5L ^ 9L) / (2L ^ 11L))
      }
      args <- list()
      args$jobDefinitionName <- private$.job_definition
      args$type <- "container"
      args$schedulingPriority <- scheduling_priority
      if (!is.null(tags)) {
        args$tags <- as.list(tags)
      }
      args$propagateTags <- propagate_tags
      if (!is.null(parameters)) {
        args$parameters <- as.list(parameters)
      }
      args$platformCapabilities <- platform_capabilities
      if (!is.null(seconds_timeout)) {
        args$timeout <- list(
          attemptDurationSeconds = seconds_timeout
        )
      }
      args$containerProperties <- list(image = image)
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
      if (length(resources)) {
        args$containerProperties$resourceRequirements <- resources
      }
      args$containerProperties$logConfiguration <- list(
        logDriver = "awslogs",
        options = list(
          "awslogs-group" = private$.log_group,
          "awslogs-region" = private$.region,
          "awslogs-stream-prefix" = private$.job_definition
        )
      )
      args
    }
  ),
  active = list(
    #' @field job_queue See [crew_aws_batch_monitor()].
    job_queue = function() {
      .subset2(private, ".job_queue")
    },
    #' @field job_definition See [crew_aws_batch_monitor()].
    job_definition = function() {
      .subset2(private, ".job_definition")
    },
    #' @field log_group See [crew_aws_batch_monitor()].
    log_group = function() {
      .subset2(private, ".log_group")
    },
    #' @field config See [crew_aws_batch_monitor()].
    config = function() {
      .subset2(private, ".config")
    },
    #' @field credentials See [crew_aws_batch_monitor()].
    credentials = function() {
      .subset2(private, ".credentials")
    },
    #' @field endpoint See [crew_aws_batch_monitor()].
    endpoint = function() {
      .subset2(private, ".endpoint")
    },
    #' @field region See [crew_aws_batch_monitor()].
    region = function() {
      .subset2(private, ".region")
    }
  ),
  public = list(
    #' @description AWS Batch job definition constructor.
    #' @return AWS Batch job definition object.
    #' @param job_queue See [crew_aws_batch_monitor()].
    #' @param job_definition See [crew_aws_batch_monitor()].
    #' @param log_group See [crew_aws_batch_monitor()].
    #' @param config See [crew_aws_batch_monitor()].
    #' @param credentials See [crew_aws_batch_monitor()].
    #' @param endpoint See [crew_aws_batch_monitor()].
    #' @param region See [crew_aws_batch_monitor()].
    initialize = function(
      job_queue = NULL,
      job_definition = NULL,
      log_group = NULL,
      config = NULL,
      credentials = NULL,
      endpoint = NULL,
      region = NULL
    ) {
      private$.job_queue <- job_queue
      private$.job_definition <- job_definition
      private$.log_group <- log_group
      private$.config <- config
      private$.credentials <- credentials
      private$.endpoint <- endpoint
      private$.region <- region
    },
    #' @description Validate the object.
    #' @return `NULL` (invisibly). Throws an error if a field is invalid.
    validate = function() {
      fields <- c(
        ".job_queue",
        ".job_definition",
        ".log_group",
        ".region"
      )
      for (field in fields) {
        crew::crew_assert(
          private[[field]],
          is.character(.),
          !anyNA(.),
          length(.) == 1L,
          nzchar(.),
          message = paste("invalid", field)
        )
      }
      crew::crew_assert(
        private$.endpoint %|||% "x",
        is.character(.),
        !anyNA(.),
        length(.) == 1L,
        nzchar(.),
        message = "endpoint must be NULL or a character of length 1."
      )
      for (field in c(".config", ".credentials")) {
        crew_assert(
          private[[field]] %|||% list(),
          is.list(.),
          message = paste("invalid", field)
        )
      }
      invisible()
    },
    #' @description Register a job definition.
    #' @details The `register()` method registers a simple
    #'   job definition using the job definition name and log group originally
    #'   supplied to [crew_aws_batch_monitor()].
    #'   Job definitions created with `$register()` are container-based
    #'   and use the AWS log driver.
    #'   For more complicated
    #'   kinds of jobs, we recommend skipping `register()`: first call
    #'   <https://www.paws-r-sdk.com/docs/batch_register_job_definition/>
    #'   to register the job definition, then supply the job definition
    #'   name to the `job_definition` argument of [crew_aws_batch_monitor()].
    #' @return A one-row `tibble` with the job definition name, ARN, and
    #'  revision number of the registered job definition.
    #' @param image Character of length 1, Docker image used for each job.
    #'   You can supply a path to an image in Docker Hub or the full URI
    #'   of an image in an Amazon ECR repository.
    #' @param memory_units Character of length 1,
    #'   either `"gigabytes"` or `"mebibytes"` to set the units of the
    #'   `memory` argument. `"gigabytes"` is simpler for EC2 jobs, but
    #'   Fargate has strict requirements about specifying exact amounts of
    #'   mebibytes (MiB). for details, read
    #'   <https://docs.aws.amazon.com/cli/latest/reference/batch/register-job-definition.html> # nolint
    #' @param platform_capabilities Optional character of length 1, either
    #'   `"EC2"` to run on EC2 or `"FARGATE"` to run on Fargate.
    #' @param memory Positive numeric of length 1, amount of memory to request
    #'   for each job.
    #' @param cpus Positive numeric of length 1, number of virtual
    #'   CPUs to request for each job.
    #' @param gpus Positive numeric of length 1, number of GPUs to
    #'   request for each job.
    #' @param seconds_timeout Optional positive numeric of length 1,
    #'   number of seconds until a job times out.
    #' @param scheduling_priority Optional nonnegative integer of length 1
    #'   between `0` and `9999`, priority of jobs. Higher-valued jobs
    #'   are scheduled first. Only applies if the job queue has a fair share
    #'   policy. Set to `NULL` to omit.
    #'   which has a fair share policy.
    #' @param tags Optional character vector of tags.
    #' @param propagate_tags Optional logical of length 1, whether to propagate
    #'   tags from the job or definition to the ECS task.
    #' @param parameters Optional character vector of key-value pairs
    #'   designating parameters for job submission.
    #' @param job_role_arn Character of length 1,
    #'   Amazon resource name (ARN) of the job role.
    #' @param execution_role_arn Character of length 1,
    #'   Amazon resource name (ARN) of the execution role.
    register = function(
      image,
      platform_capabilities = "EC2",
      memory_units = "gigabytes",
      memory = NULL,
      cpus = NULL,
      gpus = NULL,
      seconds_timeout = NULL,
      scheduling_priority = NULL,
      tags = NULL,
      propagate_tags = NULL,
      parameters = NULL,
      job_role_arn = NULL,
      execution_role_arn = NULL
    ) {
      # Covered in tests/interactive/job_definitions.R
      # nocov start
      client <- private$.client()
      args <- private$.args_register(
        image = image,
        platform_capabilities = platform_capabilities,
        memory_units = memory_units,
        memory = memory,
        cpus = cpus,
        gpus = gpus,
        seconds_timeout = seconds_timeout,
        scheduling_priority = scheduling_priority,
        tags = tags,
        propagate_tags = propagate_tags,
        parameters = parameters,
        job_role_arn = job_role_arn,
        execution_role_arn = execution_role_arn
      )
      out <- do.call(what = client$register_job_definition, args = args)
      tibble::tibble(
        name = out$jobDefinitionName,
        revision = as.integer(out$revision),
        arn = out$jobDefinitionArn
      )
      # nocov end
    },
    #' @description Attempt to deregister the job definition.
    #' @details Attempt to deregister the job definition whose name was
    #'   originally supplied to the `job_definition` argument of
    #'   [crew_aws_batch_monitor()].
    #' @return `NULL` (invisibly).
    deregister = function() {
      # Covered in tests/interactive/job_definitions.R
      # nocov start
      client <- private$.client()
      response <- self$describe()
      if (is.null(response)) {
        return(invisible())
      }
      client$deregister_job_definition(
        jobDefinition = response$jobDefinitionArn
      )
      invisible()
      # nocov end
    },
    #' @description Describe the current active revision of the job definition.
    #' @return If the job definition is not active or does not exist,
    #'   `describe()` returns `NULL`. Otherwise, it returns
    #'   a `tibble` with job definition information. Some fields
    #'   may be nested lists.
    describe = function() {
      # Covered in tests/interactive/job_definitions.R
      # nocov start
      client <- private$.client()
      response <- client$describe_job_definitions(
        jobDefinitionName = private$.job_definition,
        status = "ACTIVE"
      )
      if (!length(response$jobDefinitions)) {
        return(NULL)
      }
      out <- response$jobDefinitions[[1L]]
      for (index in seq_along(out)) {
        if (length(out[[index]]) > 1L) {
          out[[index]] <- list(out[[index]])
        }
        if (length(out[[index]]) < 1L) {
          out[[index]] <- NA
        }
      }
      tibble::as_tibble(out)
      # nocov end
    }
  )
)
