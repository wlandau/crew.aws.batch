#' @title Create an AWS Batch job definition object.
#' @export
#' @family job_definition
#' @description Create an `R6` AWS Batch job definition object.
#' @param name Character of length 1, job definition name.
crew_aws_batch_job_definition <- function(
  name = NULL
) {
  name <- as.character(name %|||% crew::crew_random_name())
  out <- crew_class_aws_batch_job_definition$new(
    name = name
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
    .name = NULL
  ),
  active = list(
    #' @field name See [crew_aws_batch_job_definition()].
    name = function() {
      .subset2(private, ".name")
    }
  ),
  public = list(
    #' @description AWS Batch job definition constructor.
    #' @return AWS Batch job definition object.
    #' @param name See [crew_aws_batch_job_definition()].
    initialize = function(
      name = NULL
    ) {
      private$.name <- name
    },
    #' @description Validate the object.
    #' @return `NULL` (invisibly). Throws an error if a field is invalid.
    validate = function() {
      crew::crew_assert(
        private$.name,
        is.character(.),
        !anyNA(.),
        nzchar(.),
        length(.) == 1L,
        message = "Job definition name must be a valid character string."
      )
      invisible()
    }
  )
)
