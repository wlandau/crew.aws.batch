#' @title Submit an AWS Batch job.
#' @export
#' @keywords internal
#' @description Not a user-side function. For internal use only.
#' @return HTTP response from submitting the job.
#' @param args_client Named list of arguments to `paws.compute::batch()`.
#' @param args_submit Named list of arguments to
#'   `paws.compute::batch()$submit_job()`.
crew_aws_batch_launch <- function(args_client, args_submit) {
  client <- crew_aws_batch_client(
    config = args_client$config,
    args = args_client
  )
  do.call(what = client$submit_job, args = args_submit)
}

#' @title Terminate an AWS Batch job.
#' @export
#' @keywords internal
#' @description Not a user-side function. For internal use only.
#' @return HTTP response from submitting the job.
#' @param args_client Named list of arguments to `paws.compute::batch()`.
#' @param job_id Character of length 1, ID of the AWS Batch job to
#'   terminate.
crew_aws_batch_terminate <- function(args_client, job_id) {
  client <- crew_aws_batch_client(
    config = args_client$config,
    args = args_client
  )
  client$terminate_job(
    jobId = job_id,
    reason = "terminated by crew controller"
  )
}

crew_aws_batch_client <- function(config, args) {
  UseMethod("crew_aws_batch_client")
}

#' @export
crew_aws_batch_client.default <- function(config, args) {
  do.call(what = paws.compute::batch, args = args)
}

#' @export
crew_aws_batch_client.crew_aws_batch_debug <- function(config, args) {
  list(
    submit_job = function(
      jobName,
      jobQueue,
      shareIdentifier,
      schedulingPriorityOverride,
      jobDefinition,
      parameters,
      containerOverrides,
      nodeOverrides,
      retryStrategy,
      propagateTags,
      timeout,
      tags,
      eksPropertiesOverride
    ) {
      envir <- environment()
      lapply(X = names(formals()), FUN = function(arg) {
        force(get(x = arg, envir = envir))
      })
      for (arg in list(jobName, jobQueue, jobDefinition)) {
        crew::crew_assert(
          arg,
          length(.) == 1L,
          is.character(.),
          !anyNA(.),
          nzchar(.),
          nchar(.) < 100L
        )
      }
      list(jobId = jobName)
    },
    terminate_job = function(jobId, reason) {
      envir <- environment()
      lapply(X = names(formals()), FUN = function(arg) {
        force(get(x = arg, envir = envir))
      })
      list(value = sample.int(n = 1e9L, size = 1L))
    }
  )
}
