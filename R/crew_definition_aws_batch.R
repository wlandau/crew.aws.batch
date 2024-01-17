#' @title Create an AWS Batch job definition object.
#' @export
#' @family definition
#' @description Create an `R6` object to manage a job definition for AWS
#'   Batch jobs.
#' @section IAM policies:
#'   In order for the AWS Batch `crew` job definition class to function
#'   properly, your IAM policy needs permission to perform the
#'   `RegisterJobDefinition`, `DeregisterJobDefinition`, and
#'   `DescribeJobDefinitions` AWS Batch API calls.
#'   For more information on AWS policies and permissions, please visit
#'   <https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html>.
#' @return An `R6` job definition object.
#' @inheritParams crew_monitor_aws_batch
#' @param job_definition Character of length 1, name of the AWS Batch
#'   job definition. The job definition might or might not exist
#'   at the time `crew_definition_aws_batch()` is called. Either way is fine.
crew_definition_aws_batch <- function(
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
  out <- crew_class_definition_aws_batch$new(
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

#' @title AWS Batch definition class
#' @export
#' @family definition
#' @description AWS Batch definition `R6` class
#' @details See [crew_definition_aws_batch()].
#' @inheritSection crew_definition_aws_batch IAM policies
crew_class_definition_aws_batch <- R6::R6Class(
  classname = "crew_class_definition_aws_batch",
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
    #' @field job_queue See [crew_definition_aws_batch()].
    job_queue = function() {
      .subset2(private, ".job_queue")
    },
    #' @field job_definition See [crew_definition_aws_batch()].
    job_definition = function() {
      .subset2(private, ".job_definition")
    },
    #' @field log_group See [crew_definition_aws_batch()].
    log_group = function() {
      .subset2(private, ".log_group")
    },
    #' @field config See [crew_definition_aws_batch()].
    config = function() {
      .subset2(private, ".config")
    },
    #' @field credentials See [crew_definition_aws_batch()].
    credentials = function() {
      .subset2(private, ".credentials")
    },
    #' @field endpoint See [crew_definition_aws_batch()].
    endpoint = function() {
      .subset2(private, ".endpoint")
    },
    #' @field region See [crew_definition_aws_batch()].
    region = function() {
      .subset2(private, ".region")
    }
  ),
  public = list(
    #' @description AWS Batch job definition constructor.
    #' @return AWS Batch job definition object.
    #' @param job_queue See [crew_definition_aws_batch()].
    #' @param job_definition See [crew_definition_aws_batch()].
    #' @param log_group See [crew_definition_aws_batch()].
    #' @param config See [crew_definition_aws_batch()].
    #' @param credentials See [crew_definition_aws_batch()].
    #' @param endpoint See [crew_definition_aws_batch()].
    #' @param region See [crew_definition_aws_batch()].
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
    #'   supplied to [crew_definition_aws_batch()].
    #'   Job definitions created with `$register()` are container-based
    #'   and use the AWS log driver.
    #'   For more complicated
    #'   kinds of jobs, we recommend skipping `register()`: first call
    #'   <https://www.paws-r-sdk.com/docs/batch_register_job_definition/>
    #'   to register the job definition, then supply the job definition
    #'   name to the `job_definition` argument of [crew_definition_aws_batch()].
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
    #' @description Attempt to deregister a revision of the job definition.
    #' @details Attempt to deregister the job definition whose name was
    #'   originally supplied to the `job_definition` argument of
    #'   [crew_definition_aws_batch()].
    #' @return `NULL` (invisibly).
    #' @param revision Finite positive integer of length 1, optional revision
    #'   number to deregister. If `NULL`, then only the highest revision
    #'   number of the job definition is deregistered, if it exists.
    deregister = function(revision = NULL) {
      # Covered in tests/interactive/definitions.R
      # nocov start
      crew::crew_assert(
        revision %|||% 1L,
        is.integer(.),
        length(.) == 1L,
        is.finite(.),
        . > 0L,
        message = "revision must be a finite positive integer of length 1."
      )
      client <- private$.client()
      if (is.null(revision)) {
        response <- self$describe(active = TRUE)
        if (is.null(response) || nrow(response) < 1L) {
          return(invisible())
        }
        revision <- max(response$revision)
      }
      definition <- paste0(private$.job_definition, ":", revision)
      client$deregister_job_definition(jobDefinition = definition)
      invisible()
      # nocov end
    },
    #' @description Describe the revisions of the job definition.
    #' @return A `tibble` with job definition information.
    #'   There is one row per revision.
    #'   Some fields may be nested lists.
    #' @param revision Positive integer of length 1, optional revision
    #'   number to describe.
    #' @param active Logical of length 1, whether to filter on just
    #'   the active job definition.
    describe = function(revision = NULL, active = FALSE) {
      # Covered in tests/interactive/definitions.R
      # nocov start
      crew::crew_assert(
        revision %|||% 1L,
        is.integer(.),
        length(.) == 1L,
        is.finite(.),
        . > 0L,
        message = "revision must be a finite positive integer of length 1."
      )
      crew::crew_assert(
        active,
        isTRUE(.) || isFALSE(.),
        message = "'active' must be either TRUE or FALSE."
      )
      status <- if_any(active, "ACTIVE", NULL)
      client <- private$.client()
      if (is.null(revision)) {
        pages <- paws.common::paginate(
          client$describe_job_definitions(
            jobDefinitionName = private$.job_definition,
            status = status
          )
        )
      } else {
        pages <- paws.common::paginate(
          client$describe_job_definitions(
            jobDefinitions = paste0(private$.job_definition, ":", revision),
            status = status
          )
        )
      }
      out <- list()
      for (page in pages) {
        for (definition in page$jobDefinitions) {
          out[[length(out) + 1L]] <- tibble::tibble(
            name = definition$jobDefinitionName,
            arn = definition$jobDefinitionArn,
            revision = as.integer(definition$revision),
            status = tolower(definition$status),
            type = definition$type,
            scheduling_priority = definition$schedulingPriority %||% NA,
            parameters = list(definition$parameters),
            retry_strategy = list(definition$retryStrategy),
            container_properties = list(definition$containerProperties),
            timeout = list(definition$timeout),
            node_properties = list(definition$nodeProperties),
            tags = list(definition$tags),
            propagate_tags = as.logical(definition$propagateTags) %||% NA,
            platform_capabilities = definition$platformCapabilities %||% NA,
            eks_properties = list(definition$eksProperties),
            container_orchestration_type =
              definition$containerOrchestrationType %||% NA
          )
        }
      }
      if (!length(out)) {
        out[[length(out) + 1L]] <- tibble::tibble(
          name = character(0L),
          arn = character(0L),
          revision = integer(0L),
          status = character(0L),
          type = character(0L),
          scheduling_priority = character(0L),
          parameters = list(),
          retry_strategy = list(),
          container_properties = list(),
          timeout = list(),
          node_properties = list(),
          tags = list(),
          propagate_tags = logical(0L),
          platform_capabilities = character(0L),
          eks_properties = list(),
          container_orchestration_type = character(0L)
        )
      }
      do.call(what = vctrs::vec_rbind, args = out)
      # nocov end
    },
    #' @description Submit an AWS Batch job with the given job definition.
    #' @details This method uses the job queue and job definition
    #'   that were supplied through [crew_definition_aws_batch()].
    #'   Any jobs submitted this way are different from the
    #'   `crew` workers that the `crew` controller starts automatically
    #'   using the AWS Batch launcher plugin.
    #'   You may use the `submit()` method in the definition for different
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
    }
  )
)
