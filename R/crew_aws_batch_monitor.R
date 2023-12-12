#' @title Create an AWS Batch monitor object.
#' @export
#' @family monitor
#' @description Create an `R6` object to manage AWS Batch jobs and
#'   job definitions.
#' @param job_queue Character of length 1, name of the AWS Batch
#'   job queue.
#' @param job_definition Character of length 1, name of the AWS Batch
#'   job definition. The job definition might or might not exist
#'   at the time `crew_aws_batch_monitor()` is called. Either way is fine.
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
      if (!is.null(memory) && identical(memory_units, "gigabytes")) {
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
    },
    .args_submit = function(
      command,
      name,
      memory_units,
      memory,
      cpus,
      gpus,
      seconds_timeout,
      share_identifier,
      scheduling_priority_override,
      tags,
      propagate_tags,
      parameters
    ) {
      crew::crew_assert(
        command,
        is.character(.),
        !anyNA(.),
        message = "job command must be a non-missing character vector"
      )
      crew::crew_assert(
        name,
        is.character(.),
        length(.) == 1L,
        !anyNA(.),
        message = "job name must be a character of length 1"
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
        scheduling_priority_override = scheduling_priority_override
      )
      for (name_amount in names(amounts)) {
        crew::crew_assert(
          amounts[[name_amount]] %|||% 1L,
          is.numeric(.),
          is.finite(.),
          . >= 0,
          message = paste(
            name_amount,
            "must be NULL or positive numeric of length 1."
          )
        )
      }
      characters <- list(
        share_identifier = share_identifier,
        tags = tags,
        parameters = parameters
      )
      for (name_chr in names(characters)) {
        crew_assert(
          tags %|||% "x",
          is.character(.),
          !anyNA(.),
          nzchar(.),
          message = paste(name_chr, "must be a character vector or NULL.")
        )
      }
      crew_assert(
        propagate_tags %|||% TRUE,
        isTRUE(.) || isFALSE(.),
        message = "propagate_tags must be NULL or TRUE or FALSE"
      )
      if (!is.null(memory) && identical(memory_units, "gigabytes")) {
        memory <- memory * ((5L ^ 9L) / (2L ^ 11L))
      }
      args <- list()
      args$jobName <- name
      args$jobQueue <- private$.job_queue
      if (!is.null(share_identifier)) {
        args$shareIdentifier <- share_identifier
      }
      if (!is.null(scheduling_priority_override)) {
        args$schedulingPriorityOverride <- scheduling_priority_override
      }
      args$jobDefinition <- private$.job_definition
      args$parameters <- parameters
      args$tags <- tags
      args$propagateTags <- propagate_tags
      if (!is.null(seconds_timeout)) {
        args$timeout <- list(
          attemptDurationSeconds = seconds_timeout
        )
      }
      args$containerOverrides <- list(command = as.list(command))
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
        args$containerOverrides$resourceRequirements <- resources
      }
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
          message = paste(field, "must be a nonempty character of length 1")
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
    #'   between `0` and `9999`, priority of jobs. Jobs with higher-valued
    #'   priorities are scheduled first.
    #'   The priority only applies if the job queue has a fair share
    #'   policy. Set to `NULL` to omit.
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
      # Covered in tests/interactive/definitions.R
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
      # Covered in tests/interactive/definitions.R
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
      # Covered in tests/interactive/definitions.R
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
    },
    #' @description Submit a single AWS Batch job to the given job queue
    #'   under the given job definition.
    #' @details This method uses the job queue and job definition
    #'   that were supplied through [crew_aws_batch_monitor()].
    #'   Any jobs submitted this way are different from the
    #'   `crew` workers that the `crew` controller starts automatically
    #'   using the AWS Batch launcher plugin.
    #'   You may use the `submit()` method in the monitor for different
    #'   purposes such as testing.
    #' @return A one-row `tibble` with the name, ID, and
    #'   Amazon resource name (ARN) of the job.
    #' @param command Character vector with the command
    #'   to submit for the job. Usually a Linux shell command
    #'   with each term in its own character string.
    #' @param name Character of length 1 with the job name.
    #' @param memory_units Character of length 1,
    #'   either `"gigabytes"` or `"mebibytes"` to set the units of the
    #'   `memory` argument. `"gigabytes"` is simpler for EC2 jobs, but
    #'   Fargate has strict requirements about specifying exact amounts of
    #'   mebibytes (MiB). for details, read
    #'   <https://docs.aws.amazon.com/cli/latest/reference/batch/register-job-definition.html> # nolint
    #' @param memory Positive numeric of length 1, amount of memory to request
    #'   for each job.
    #' @param cpus Positive numeric of length 1, number of virtual
    #'   CPUs to request for each job.
    #' @param gpus Positive numeric of length 1, number of GPUs to
    #'   request for each job.
    #' @param seconds_timeout Optional positive numeric of length 1,
    #'   number of seconds until a job times out.
    #' @param share_identifier Character of length 1 with the share
    #'   identifier of the job. Only applies if the job queue has a
    #'   scheduling policy. Read the official AWS Batch documentation
    #'   for details.
    #' @param scheduling_priority_override Optional nonnegative integer
    #'   of length between `0` and `9999`, priority of the job.
    #'   This value overrides the priority in the job definition.
    #'   Jobs with higher-valued priorities are scheduled first.
    #'   The priority applies if the job queue has a fair share policy.
    #'   Set to `NULL` to omit.
    #' @param tags Optional character vector of tags.
    #' @param propagate_tags Optional logical of length 1, whether to propagate
    #'   tags from the job or definition to the ECS task.
    #' @param parameters Optional character vector of key-value pairs
    #'   designating parameters for job submission.
    submit = function(
      command = c("sleep", "300"),
      name = paste0("crew-aws-batch-job-", crew::crew_random_name()),
      memory_units = "gigabytes",
      memory = NULL,
      cpus = NULL,
      gpus = NULL,
      seconds_timeout = NULL,
      share_identifier = NULL,
      scheduling_priority_override = NULL,
      tags = NULL,
      propagate_tags = NULL,
      parameters = NULL
    ) {
      # Covered in tests/interactive/jobs.R
      # nocov start
      args <- private$.args_submit(
        command = command,
        name = name,
        memory_units = memory_units,
        memory = memory,
        cpus = cpus,
        gpus = gpus,
        seconds_timeout = seconds_timeout,
        share_identifier = share_identifier,
        scheduling_priority_override = scheduling_priority_override,
        tags = tags,
        propagate_tags = propagate_tags,
        parameters = parameters
      )
      client <- private$.client()
      out <- do.call(what = client$submit_job, args = args)
      tibble::tibble(
        name = out$jobName,
        id = out$jobId,
        arn = out$jobArn
      )
      # nocov end
    },
    #' @description Terminate an AWS Batch job.
    #' @return `NULL` (invisibly).
    #' @param id Character of length 1, ID of the AWS Batch job to terminate.
    #' @param reason Character of length 1, natural language explaining
    #'   the reason the job was terminated.
    terminate = function(
      id,
      reason = "terminated by crew.aws.batch monitor"
    ) {
      # Covered in tests/interactive/jobs.R
      # nocov start
      crew::crew_assert(
        id,
        is.character(.),
        !anyNA(.),
        length(.) == 1L,
        nzchar(.),
        message = "job ID must be a valid character of length 1"
      )
      crew::crew_assert(
        reason,
        is.character(.),
        !anyNA(.),
        length(.) == 1L,
        nzchar(.),
        message = "'reason' must be a valid character of length 1"
      )
      client <- private$.client()
      client$terminate_job(jobId = id, reason = reason)
      invisible()
      # nocov end
    },
    #' @description Get the status of a single job
    #' @return A one-row `tibble` with information about the job.
    #' @param id Character of length 1, job ID. This is different
    #'   from the user-supplied job name.
    status = function(id) {
      # Covered in tests/interactive/jobs.R
      # nocov start
      crew::crew_assert(
        id,
        is.character(.),
        !anyNA(.),
        nzchar(.),
        length(.) == 1L,
        message = "'id' must be a valid character of length 1"
      )
      client <- private$.client()
      result <- client$describe_jobs(jobs = id)
      if (!length(result$jobs)) {
        return(
          tibble::tibble(
            name = character(0L),
            id = character(0L),
            arn = character(0L),
            status = character(0L),
            reason = character(0L),
            created = numeric(0L),
            started = numeric(0L),
            stopped = numeric(0L)
          )
        )
      }
      out <- client$describe_jobs(jobs = id)$jobs[[1L]]
      tibble::tibble(
        name = out$jobName,
        id = out$jobId,
        arn = out$jobArn,
        status = tolower(out$status),
        reason = if_any(
          length(out$statusReason),
          out$statusReason,
          NA_character_
        ),
        created = out$createdAt,
        started = if_any(length(out$startedAt), out$startedAt, NA_real_),
        stopped = if_any(length(out$stoppedAt), out$stoppedAt, NA_real_)
      )
      # nocov end
    },
    #' @description Get the CloudWatch log of a job.
    #' @details This method assumes the job has log driver `"awslogs"`
    #'   (specifying AWS CloudWatch) and that the log group is the one
    #'   prespecified in the `log_group` argument of
    #'   [crew_aws_batch_monitor()]. This method cannot use
    #'   other log drivers such as Splunk, and it will fail if the log
    #'   group is wrong or missing.
    #' @return A `tibble` with log information.
    #' @param id Character of length 1, job ID. This is different
    #'   from the user-supplied job name.
    #' @param start_from_head Logical of length 1, whether to print earlier
    #'   log events before later ones.
    log = function(id, start_from_head = FALSE) {
      # Covered in tests/interactive/jobs.R
      # nocov start
      crew::crew_assert(
        id,
        is.character(.),
        !anyNA(.),
        nzchar(.),
        length(.) == 1L,
        message = "'id' must be a valid character of length 1"
      )
      client <- private$.client()
      result <- client$describe_jobs(jobs = id)
      null_log <- tibble::tibble(
        message = character(0L),
        timestamp = character(0L),
        ingestion_time = character(0L)
      )
      if (!length(result$jobs)) {
        return(null_log)
      }
      log_stream_name <- result$jobs[[1L]]$container$logStreamName
      client <- paws.management::cloudwatchlogs(
        config = as.list(private$.config),
        credentials = as.list(private$.credentials),
        endpoint = private$.endpoint,
        region = private$.region
      )
      pages <- list( # TODO: paws.common::paginate() # nolint
        client$get_log_events(
          logGroupName = private$.log_group,
          logStreamName = log_stream_name,
          startFromHead = start_from_head
        )
      )
      out <- list()
      for (page in pages) {
        for (event in page$events) {
          out[[length(out) + 1L]] <- tibble::tibble(
            message = event$message,
            timestamp = event$timestamp,
            ingestion_time = event$ingestionTime
          )
        }
      }
      if (!length(out)) {
        return(null_log)
      }
      do.call(what = rbind, args = out)
      # nocov end
    },
    #' @description List all the jobs in the given job queue
    #'   with the given job definition.
    #' @details The output only includes jobs under the
    #'   job queue and job definition
    #'   that were supplied through [crew_aws_batch_monitor()].
    #' @return A `tibble` with one row per job and columns
    #'   with job information.
    #' @param status Character vector of job states. Results are limited
    #'   to these job states.
    jobs = function(
      status = c(
        "submitted",
        "pending",
        "runnable",
        "starting",
        "running",
        "succeeded",
        "failed"
      )
    ) {
      # Covered in tests/interactive/jobs.R
      # nocov start
      crew::crew_assert(
        status,
        is.character(.),
        !anyNA(.),
        nzchar(.),
        message = "'status' must be a valid character vector"
      )
      crew::crew_assert(
        status,
        . %in% c(
          "submitted",
          "pending",
          "runnable",
          "starting",
          "running",
          "succeeded",
          "failed"
        ),
        message = paste(
          "elements of 'status' must be \"submitted\", \"pending\",",
          "\"runnable\", \"starting\", \"running\", \"succeeded\", or",
          "\"failed\"."
        )
      )
      status <- unique(status)
      filters <- list(
        list(
          name = "JOB_DEFINITION",
          values = private$.job_definition
        )
      )
      client <- private$.client()
      pages <- paws.common::paginate(
        Operation = client$list_jobs(
          jobQueue = private$.job_queue,
          filters = filters
        )
      )
      out <- list()
      for (page in pages) {
        for (job in page$jobSummaryList) {
          out[[length(out) + 1L]] <- tibble::tibble(
            name = job$jobName,
            id = job$jobId,
            arn = job$jobArn,
            status = job$status,
            reason = if_any(
              length(job$statusReason),
              job$statusReason,
              NA_character_
            ),
            created = job$createdAt,
            started = if_any(length(job$startedAt), job$startedAt, NA_real_),
            stopped = if_any(length(job$stoppedAt), job$stoppedAt, NA_real_)
          )
        }
      }
      if (!length(out)) {
        out[[length(out) + 1L]] <- tibble::tibble(
          name = character(0L),
          id = character(0L),
          arn = character(0L),
          status = character(0L),
          reason = character(0L),
          created = numeric(0L),
          started = numeric(0L),
          stopped = numeric(0L)
        )
      }
      out <- do.call(what = rbind, args = out)
      out$status <- tolower(out$status)
      out[out$status %in% status, ]
      # nocov end
    },
    #' @description List active jobs: submitted, pending,
    #'   runnable, starting, or running (not succeeded or failed).
    #' @details The output only includes jobs under the
    #'   job queue and job definition
    #'   that were supplied through [crew_aws_batch_monitor()].
    #' @return A `tibble` with one row per job and columns
    #'   with job information.
    active = function() {
      # Covered in tests/interactive/jobs.R
      # nocov start
      status <- c(
        "submitted",
        "pending",
        "runnable",
        "starting",
        "running"
      )
      self$jobs(status = status)
      # nocov end
    },
    #' @description List inactive jobs: ones whose status
    #'   is succeeded or failed (not submitted, pending,
    #'   runnable, starting, or running).
    #' @details The output only includes jobs under the
    #'   job queue and job definition
    #'   that were supplied through [crew_aws_batch_monitor()].
    #' @return A `tibble` with one row per job and columns
    #'   with job information.
    inactive = function() {
      # Covered in tests/interactive/jobs.R
      # nocov start
      self$jobs(status = c("succeeded", "failed"))
      # nocov end
    },
    #' @description List jobs whose status is `"submitted"`.
    #' @details The output only includes jobs under the
    #'   job queue and job definition
    #'   that were supplied through [crew_aws_batch_monitor()].
    #' @return A `tibble` with one row per job and columns
    #'   with job information.
    submitted = function() {
      # Covered in tests/interactive/jobs.R
      # nocov start
      self$jobs(status = "submitted")
      # nocov end
    },
    #' @description List jobs whose status is `"pending"`.
    #' @details The output only includes jobs under the
    #'   job queue and job definition
    #'   that were supplied through [crew_aws_batch_monitor()].
    #' @return A `tibble` with one row per job and columns
    #'   with job information.
    pending = function() {
      # Covered in tests/interactive/jobs.R
      # nocov start
      self$jobs(status = "pending")
      # nocov end
    },
    #' @description List jobs whose status is `"runnable"`.
    #' @details The output only includes jobs under the
    #'   job queue and job definition
    #'   that were supplied through [crew_aws_batch_monitor()].
    #' @return A `tibble` with one row per job and columns
    #'   with job information.
    runnable = function() {
      # Covered in tests/interactive/jobs.R
      # nocov start
      self$jobs(status = "runnable")
      # nocov end
    },
    #' @description List jobs whose status is `"starting"`.
    #' @details The output only includes jobs under the
    #'   job queue and job definition
    #'   that were supplied through [crew_aws_batch_monitor()].
    #' @return A `tibble` with one row per job and columns
    #'   with job information.
    starting = function() {
      # Covered in tests/interactive/jobs.R
      # nocov start
      self$jobs(status = "starting")
      # nocov end
    },
    #' @description List jobs whose status is `"running"`.
    #' @details The output only includes jobs under the
    #'   job queue and job definition
    #'   that were supplied through [crew_aws_batch_monitor()].
    #' @return A `tibble` with one row per job and columns
    #'   with job information.
    running = function() {
      # Covered in tests/interactive/jobs.R
      # nocov start
      self$jobs(status = "running")
      # nocov end
    },
    #' @description List jobs whose status is `"succeeded"`.
    #' @details The output only includes jobs under the
    #'   job queue and job definition
    #'   that were supplied through [crew_aws_batch_monitor()].
    #' @return A `tibble` with one row per job and columns
    #'   with job information.
    succeeded = function() {
      # Covered in tests/interactive/jobs.R
      # nocov start
      self$jobs(status = "succeeded")
      # nocov end
    },
    #' @description List jobs whose status is `"failed"`.
    #' @details The output only includes jobs under the
    #'   job queue and job definition
    #'   that were supplied through [crew_aws_batch_monitor()].
    #' @return A `tibble` with one row per job and columns
    #'   with job information.
    failed = function() {
      # Covered in tests/interactive/jobs.R
      # nocov start
      self$jobs(status = "failed")
      # nocov end
    }
  )
)
