#' @title Create an AWS Batch monitor object.
#' @export
#' @family monitor
#' @description Create an `R6` object to list, inspect, and terminate
#'   AWS Batch jobs.
#' @section IAM policies:
#'   In order for the AWS Batch `crew` monitor class to function
#'   properly, your IAM policy needs permission to perform the `SubmitJob`,
#'   `TerminateJob`, `ListJobs`, and `DescribeJobs` AWS Batch API calls.
#'   In addition, to download CloudWatch logs with the `log()` method,
#'   your IAM policy also needs permission to perform the `GetLogEvents`
#'   CloudWatch logs API call.
#'   For more information on AWS policies and permissions, please visit
#'   <https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html>.
#' @param job_queue Character vector of names of AWS Batch job queues.
#'   As of `crew.aws.batch` version 0.0.8 and above, you can supply
#'   more than one job queue. Methods like `jobs()` and `active()`
#'   will query all the job queues given.
#' @param job_definition Character string, name of the AWS Batch
#'   job definition.
#' @param log_group Character of length 1,
#'   AWS Batch CloudWatch log group to get job logs.
#'   The default log group is often `"/aws/batch/job"`, but not always.
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
crew_monitor_aws_batch <- function(
  job_queue,
  job_definition,
  log_group = "/aws/batch/job",
  config = NULL,
  credentials = NULL,
  endpoint = NULL,
  region = NULL
) {
  region <- region %|||% paws.common::get_config()$region
  region <- region %|||chr% Sys.getenv("AWS_REGION", unset = "")
  region <- region %|||chr% Sys.getenv("AWS_DEFAULT_REGION", unset = "")
  out <- crew_class_monitor_aws_batch$new(
    job_queue = unique(job_queue),
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
#' @description AWS Batch monitor `R6` class
#' @details See [crew_monitor_aws_batch()].
#' @inheritSection crew_monitor_aws_batch IAM policies
crew_class_monitor_aws_batch <- R6::R6Class(
  classname = "crew_class_monitor_aws_batch",
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
    }
  ),
  active = list(
    #' @field job_queue See [crew_monitor_aws_batch()].
    job_queue = function() {
      .subset2(private, ".job_queue")
    },
    #' @field job_definition See [crew_monitor_aws_batch()].
    job_definition = function() {
      .subset2(private, ".job_definition")
    },
    #' @field log_group See [crew_monitor_aws_batch()].
    log_group = function() {
      .subset2(private, ".log_group")
    },
    #' @field config See [crew_monitor_aws_batch()].
    config = function() {
      .subset2(private, ".config")
    },
    #' @field credentials See [crew_monitor_aws_batch()].
    credentials = function() {
      .subset2(private, ".credentials")
    },
    #' @field endpoint See [crew_monitor_aws_batch()].
    endpoint = function() {
      .subset2(private, ".endpoint")
    },
    #' @field region See [crew_monitor_aws_batch()].
    region = function() {
      .subset2(private, ".region")
    }
  ),
  public = list(
    #' @description AWS Batch job definition constructor.
    #' @return AWS Batch job definition object.
    #' @param job_queue See [crew_monitor_aws_batch()].
    #' @param job_definition See [crew_monitor_aws_batch()].
    #' @param log_group See [crew_monitor_aws_batch()].
    #' @param config See [crew_monitor_aws_batch()].
    #' @param credentials See [crew_monitor_aws_batch()].
    #' @param endpoint See [crew_monitor_aws_batch()].
    #' @param region See [crew_monitor_aws_batch()].
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
          message = paste(field, "must be a nonempty character string")
        )
      }
      crew::crew_assert(
        private[[".job_queue"]],
        is.character(.),
        !anyNA(.),
        length(.) > 0L,
        nzchar(.),
        message = paste(
          "job_queue must be a valid nonempty character vector of",
          "AWS Batch job queue names."
        )
      )
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
    #' @description Terminate one or more AWS Batch jobs.
    #' @return `NULL` (invisibly).
    #' @param ids Character vector with the IDs of the AWS Batch jobs
    #'   to terminate. Leave as `NULL` if `all` is `TRUE`.
    #' @param all `TRUE` to terminate all jobs belonging to
    #'   the previously specified job definition. `FALSE` to terminate
    #'   only the job IDs given in the `ids` argument.
    #' @param reason Character of length 1, natural language explaining
    #'   the reason the job was terminated.
    #' @param verbose Logical of length 1, whether to show a progress bar
    #'   if the R process is interactive and `length(ids)` is greater than 1.
    terminate = function(
      ids = NULL,
      all = FALSE,
      reason = "cancelled/terminated by crew.aws.batch monitor",
      verbose = TRUE
    ) {
      # Covered in tests/interactive/jobs.R
      # nocov start
      crew::crew_assert(
        ids %|||% "x",
        is.character(.),
        length(.) > 0L,
        !anyNA(.),
        nzchar(.),
        message = "'ids' must be a valid nonempty character"
      )
      crew::crew_assert(
        all,
        isTRUE(.) || isFALSE(.),
        message = "'all' must be TRUE or FALSE."
      )
      crew::crew_assert(
        reason,
        is.character(.),
        !anyNA(.),
        length(.) == 1L,
        nzchar(.),
        message = "'reason' must be a valid character of length 1"
      )
      crew::crew_assert(verbose, isTRUE(.) || isFALSE(.))
      client <- private$.client()
      if (all) {
        ids <- self$active()$id
      }
      progress <- progress_init(verbose = verbose, total = length(ids))
      for (id in ids) {
        client$cancel_job(jobId = id, reason = reason)
        client$terminate_job(jobId = id, reason = reason)
        progress_update(progress)
      }
      progress_terminate(progress)
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
        message = "'id' must be a single valid character string"
      )
      client <- private$.client()
      result <- client$describe_jobs(jobs = id)
      if (!length(result$jobs)) {
        return(
          tibble::tibble(
            name = character(0L),
            id = character(0L),
            arn = character(0L),
            queue = character(0L),
            status = character(0L),
            reason = character(0L),
            created = as.POSIXct(numeric(0L)),
            started = as.POSIXct(numeric(0L)),
            stopped = as.POSIXct(numeric(0L))
          )
        )
      }
      out <- result$jobs[[1L]]
      tibble::tibble(
        name = out$jobName,
        id = out$jobId,
        arn = out$jobArn,
        queue = basename(out$jobQueue),
        status = tolower(out$status),
        reason = if_any(
          length(out$statusReason),
          out$statusReason,
          paste(
            "EMPTY. Either the job has not completed yet or the DescribeJobs",
            "API call is missing a status reason. In the latter case,",
            "you may need a different type of query to get the status reason."
          )
        ),
        created = as_timestamp(out$createdAt),
        started = as_timestamp(out$startedAt),
        stopped = as_timestamp(out$stoppedAt)
      )
      # nocov end
    },
    #' @description Get the CloudWatch log of a job.
    #' @details This method assumes the job has log driver `"awslogs"`
    #'   (specifying AWS CloudWatch) and that the log group is the one
    #'   prespecified in the `log_group` argument of
    #'   [crew_monitor_aws_batch()]. This method cannot use
    #'   other log drivers such as Splunk, and it will fail if the log
    #'   group is wrong or missing.
    #' @return `log()` invisibly returns a `tibble` with log information
    #'   and writes the messages to the stream or path given by the
    #'   `path` argument.
    #' @param id Character of length 1, job ID. This is different
    #'   from the user-supplied job name.
    #' @param path Character string or stream (e.g. `stdout()`),
    #'   file path or connection passed to the `con` argument of
    #'   `writeLines()` to print the log messages.
    #'   Set to `nullfile()` to suppress output
    #'   (and use the invisibly returned `tibble` object instead).
    #' @param start_from_head Logical of length 1, whether to print earlier
    #'   log events before later ones.
    log = function(
      id,
      path = stdout(),
      start_from_head = FALSE
    ) {
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
        timestamp = as.POSIXct(numeric(0L)),
        ingestion_time = as.POSIXct(numeric(0L))
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
      pages <- tryCatch(
        paws.common::paginate(
          client$get_log_events(
            logGroupName = private$.log_group,
            logStreamName = log_stream_name,
            startFromHead = start_from_head
          ),
          StopOnSameToken = TRUE
        ),
        error = function(condition) {
          crew::crew_assert(
            FALSE,
            message = paste(
              "Error getting log data. If the job has not started yet,",
              "please wait for it to start. Otherwise, the original error",
              "message could be misleading. Original error:",
              conditionMessage(condition)
            )
          )
        }
      )
      out <- list()
      for (page in pages) {
        for (event in page$events) {
          out[[length(out) + 1L]] <- tibble::tibble(
            message = event$message,
            timestamp = as_timestamp(event$timestamp),
            ingestion_time = as_timestamp(event$ingestionTime)
          )
        }
      }
      if (!length(out)) {
        return(null_log)
      }
      out <- do.call(what = vctrs::vec_rbind, args = out)
      writeLines(text = out$message, con = path)
      invisible(out)
      # nocov end
    },
    #' @description List all the jobs in the given job queue
    #'   with the given job definition.
    #' @details The output only includes jobs under the
    #'   job queue and job definition
    #'   that were supplied through [crew_monitor_aws_batch()].
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
      out <- list()
      for (job_queue in private$.job_queue) {
        pages <- paws.common::paginate(
          Operation = client$list_jobs(
            jobQueue = job_queue,
            filters = filters
          )
        )
        for (page in pages) {
          for (job in page$jobSummaryList) {
            out[[length(out) + 1L]] <- tibble::tibble(
              name = job$jobName,
              id = job$jobId,
              arn = job$jobArn,
              queue = job_queue,
              status = job$status,
              reason = if_any(
                length(job$statusReason),
                job$statusReason,
                paste(
                  "EMPTY. Either the job has not concluded or the",
                  "ListJobs API call cannot show the status reason.",
                  "In the latter case, status() is more reliable",
                  "because it uses DescribeJobs instead of ListJobs",
                  "(c.f. https://github.com/aws/aws-sdk-js/issues/4587)."
                )
              ),
              created = as_timestamp(job$createdAt),
              started = as_timestamp(job$startedAt),
              stopped = as_timestamp(job$stoppedAt)
            )
          }
        }
      }
      if (!length(out)) {
        out[[length(out) + 1L]] <- tibble::tibble(
          name = character(0L),
          id = character(0L),
          arn = character(0L),
          queue = character(0L),
          status = character(0L),
          reason = character(0L),
          created = as.POSIXct(numeric(0L)),
          started = as.POSIXct(numeric(0L)),
          stopped = as.POSIXct(numeric(0L))
        )
      }
      out <- do.call(what = vctrs::vec_rbind, args = out)
      out$status <- tolower(out$status)
      out[out$status %in% status, ]
      # nocov end
    },
    #' @description List active jobs: submitted, pending,
    #'   runnable, starting, or running (not succeeded or failed).
    #' @details The output only includes jobs under the
    #'   job queue and job definition
    #'   that were supplied through [crew_monitor_aws_batch()].
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
    #'   that were supplied through [crew_monitor_aws_batch()].
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
    #'   that were supplied through [crew_monitor_aws_batch()].
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
    #'   that were supplied through [crew_monitor_aws_batch()].
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
    #'   that were supplied through [crew_monitor_aws_batch()].
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
    #'   that were supplied through [crew_monitor_aws_batch()].
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
    #'   that were supplied through [crew_monitor_aws_batch()].
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
    #'   that were supplied through [crew_monitor_aws_batch()].
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
    #'   that were supplied through [crew_monitor_aws_batch()].
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
