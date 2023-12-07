#' @title Create an AWS Batch job definition object.
#' @export
#' @family job_definition
#' @description Create an `R6` AWS Batch job definition object.
#' @param name Character of length 1, job definition name.
#' @param log_group Character of length 1,
#'   AWS Batch CloudWatch log group to get job logs.
#'   The default log group is often "/aws/batch/job", but not always.
#'   It is not easy to get the log group of an active job or job
#'   definition, so if you have a non-default log group and you do not
#'   know its name, please consult your system administrator.
#' @param log_group_region Character of length 1, region of the log group.
#'   Must be a valid region name such as `"us-east-1"` or `"us-east-2"`.
crew_aws_batch_job_definition <- function(
  name = paste0("crew-aws-batch-job-definition-", crew::crew_random_name()),
  log_group = "/aws/batch/job",
  log_group_region = "us-east-1"
) {
  out <- crew_class_aws_batch_job_definition$new(
    name = name,
    log_group = log_group,
    log_group_region = log_group_region
  )
  out$validate()
  out
}

#' @title AWS Batch job definition class
#' @export
#' @family plugin_aws_batch
#' @description AWS Batch job definition `R6` class
#' @details See [crew_aws_batch_job_definition()].
crew_class_aws_batch_job_definition <- R6::R6Class(
  classname = "crew_class_aws_batch_job_definition",
  cloneable = FALSE,
  private = list(
    .name = NULL,
    .log_group = NULL,
    .log_group_region = NULL
  ),
  active = list(
    #' @field name See [crew_aws_batch_job_definition()].
    name = function() {
      .subset2(private, ".name")
    },
    #' @field log_group See [crew_aws_batch_job_definition()].
    log_group = function() {
      .subset2(private, ".log_group")
    },
    #' @field log_group_region See [crew_aws_batch_job_definition()].
    log_group_region = function() {
      .subset2(private, ".log_group_region")
    }
  ),
  public = list(
    #' @description AWS Batch job definition constructor.
    #' @return AWS Batch job definition object.
    #' @param name See [crew_aws_batch_job_definition()].
    #' @param log_group See [crew_aws_batch_job_definition()].
    #' @param log_group_region See [crew_aws_batch_job_definition()].
    initialize = function(
      name = NULL,
      log_group = NULL,
      log_group_region = NULL
    ) {
      private$.name <- name
      private$.log_group <- log_group
      private$.log_group_region <- log_group_region
    },
    #' @description Validate the object.
    #' @return `NULL` (invisibly). Throws an error if a field is invalid.
    validate = function() {
      for (field in c(".name", ".log_group", ".log_group_region")) {
        crew::crew_assert(
          private[[field]],
          is.character(.),
          !anyNA(.),
          length(.) == 1L,
          nzchar(.),
          message = paste("invalid", field)
        )
      }
      invisible()
    },
    #' @description Register the job definition as a simple container-based
    #'   definition.
    #' @details This method registers a simple
    #'   job definition under the name and log group
    #'   supplied to [crew_aws_batch_job_definition()].
    #'   Job definitions created with `$register()` are container-based
    #'   and use the AWS log driver.
    #'   For more complicated
    #'   kinds of jobs, we recommend skipping `$register()`: first call
    #'   <https://www.paws-r-sdk.com/docs/batch_register_job_definition/>
    #'   to register the job definition, then supply the job definition
    #'   name to the `name` argument of [crew_aws_batch_job_definition()].
    #' @param image Character of length 1, Docker image used for each job.
    #'   You can supply a path to an image in Docker Hub or the full URI
    #'   of an image in an Amazohn ECR repository.
    #' @param units_memory Character of length 1,
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
    #' @param job_role_arn 
    #' @param execution_role_arn 
    register = function(
      image,
      platform_capabilities = "EC2",
      units_memory = "gigabytes",
      memory = NULL,
      cpus = NULL,
      gpus = NULL,
      seconds_timeout = NULL,
      scheduling_priority = NULL,
      tags = NULL,
      propagate_tags = NULL,
      job_role_arn = NULL,
      execution_role_arn = NULL
    ) {
      browser()
      
      
    }
  )
)
