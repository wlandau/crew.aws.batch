#' @title Create a controller with an AWS Batch launcher.
#' @export
#' @family plugin_aws_batch
#' @description Create an `R6` object to submit tasks and
#'   launch workers on AWS Batch workers.
#' @inheritSection crew_launcher_aws_batch IAM policies
#' @inheritSection crew_launcher_aws_batch AWS arguments
#' @inheritSection crew_launcher_aws_batch Verbosity
#' @inheritParams crew::crew_client
#' @inheritParams crew_launcher_aws_batch
#' @inheritParams crew::crew_controller
#' @examples
#' if (identical(Sys.getenv("CREW_EXAMPLES"), "true")) {
#' controller <- crew_controller_aws_batch(
#'   aws_batch_job_definition = "YOUR_JOB_DEFINITION_NAME",
#'   aws_batch_job_queue = "YOUR_JOB_QUEUE_NAME"
#' )
#' controller$start()
#' controller$push(name = "task", command = sqrt(4))
#' controller$wait()
#' controller$pop()$result
#' controller$terminate()
#' }
crew_controller_aws_batch <- function(
  name = NULL,
  workers = 1L,
  host = NULL,
  port = NULL,
  tls = crew::crew_tls(mode = "automatic"),
  tls_enable = NULL,
  tls_config = NULL,
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
  client <- crew::crew_client(
    name = name,
    workers = workers,
    host = host,
    port = port,
    tls = tls,
    tls_enable = tls_enable,
    tls_config = tls_config,
    seconds_interval = seconds_interval,
    seconds_timeout = seconds_timeout
  )
  launcher <- crew_launcher_aws_batch(
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
  controller <- crew::crew_controller(client = client, launcher = launcher)
  controller$validate()
  controller
}
