# Create a controller with an AWS Batch launcher.

Create an `R6` object to submit tasks and launch workers on AWS Batch
workers.

## Usage

``` r
crew_controller_aws_batch(
  name = NULL,
  workers = 1L,
  host = NULL,
  port = NULL,
  tls = crew::crew_tls(mode = "automatic"),
  tls_enable = NULL,
  tls_config = NULL,
  serialization = NULL,
  profile = crew::crew_random_name(),
  seconds_interval = 0.5,
  seconds_timeout = 60,
  seconds_launch = 1800,
  seconds_idle = 300,
  seconds_wall = Inf,
  retry_tasks = NULL,
  tasks_max = Inf,
  tasks_timers = 0L,
  reset_globals = TRUE,
  reset_packages = FALSE,
  reset_options = FALSE,
  garbage_collection = FALSE,
  crashes_error = NULL,
  processes = NULL,
  r_arguments = c("--no-save", "--no-restore"),
  crashes_max = 5L,
  backup = NULL,
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
)
```

## Arguments

- name:

  Character string, name of the launcher. If the name is `NULL`, then a
  name is automatically generated when the launcher starts.

- workers:

  Maximum number of workers to run concurrently when auto-scaling,
  excluding task retries and manual calls to `launch()`. Special workers
  allocated for task retries do not count towards this limit, so the
  number of workers running at a given time may exceed this maximum. A
  smaller number of workers may run if the number of executing tasks is
  smaller than the supplied value of the `workers` argument.

- host:

  IP address of the `mirai` client to send and receive tasks. If `NULL`,
  the host defaults to `nanonext::ip_addr()[1]`.

- port:

  TCP port to listen for the workers. If `NULL`, then an available
  ephemeral port is automatically chosen. Controllers running
  simultaneously on the same computer (as in a controller group) must
  not share the same TCP port.

- tls:

  A TLS configuration object from
  [`crew_tls()`](https://wlandau.github.io/crew/reference/crew_tls.html).

- tls_enable:

  Deprecated on 2023-09-15 in version 0.4.1. Use argument `tls` instead.

- tls_config:

  Deprecated on 2023-09-15 in version 0.4.1. Use argument `tls` instead.

- serialization:

  Either `NULL` (default) or an object produced by
  [`mirai::serial_config()`](https://nanonext.r-lib.org/reference/serial_config.html)
  to control the serialization of data sent to workers. This can help
  with either more efficient data transfers or to preserve attributes of
  otherwise non-exportable objects (such as `torch` tensors or `arrow`
  tables). See
  [`?mirai::serial_config`](https://nanonext.r-lib.org/reference/serial_config.html)
  for details.

- profile:

  Character string, compute profile for
  [`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html).

- seconds_interval:

  Number of seconds between polling intervals waiting for certain
  internal synchronous operations to complete. In certain cases,
  exponential backoff is used with this argument passed to `seconds_max`
  in a
  [`crew_throttle()`](https://wlandau.github.io/crew/reference/crew_throttle.html)
  object.

- seconds_timeout:

  Number of seconds until timing out while waiting for certain
  synchronous operations to complete, such as checking
  [`mirai::info()`](https://mirai.r-lib.org/reference/info.html).

- seconds_launch:

  Seconds of startup time to allow. A worker is unconditionally assumed
  to be alive from the moment of its launch until `seconds_launch`
  seconds later. After `seconds_launch` seconds, the worker is only
  considered alive if it is actively connected to its assign websocket.

- seconds_idle:

  Maximum number of seconds that a worker can idle since the completion
  of the last task. If exceeded, the worker exits. But the timer does
  not launch until `tasks_timers` tasks have completed. See the
  `idletime` argument of
  [`mirai::daemon()`](https://mirai.r-lib.org/reference/daemon.html).
  `crew` does not excel with perfectly transient workers because it does
  not micromanage the assignment of tasks to workers, so please allow
  enough idle time for a new worker to be delegated a new task.

- seconds_wall:

  Soft wall time in seconds. The timer does not launch until
  `tasks_timers` tasks have completed. See the `walltime` argument of
  [`mirai::daemon()`](https://mirai.r-lib.org/reference/daemon.html).

- retry_tasks:

  Deprecated on 2025-01-13 (`crew` version 0.10.2.9002).

- tasks_max:

  Maximum number of tasks that a worker will do before exiting. Also
  determines how often the controller auto-scales. See the Auto-scaling
  section for details.

- tasks_timers:

  Number of tasks to do before activating the timers for `seconds_idle`
  and `seconds_wall`. See the `timerstart` argument of
  [`mirai::daemon()`](https://mirai.r-lib.org/reference/daemon.html).

- reset_globals:

  `TRUE` to reset global environment variables between tasks, `FALSE` to
  leave them alone.

- reset_packages:

  `TRUE` to detach any packages loaded during a task (runs between each
  task), `FALSE` to leave packages alone. In either case, the namespaces
  are not detached.

- reset_options:

  `TRUE` to reset global options to their original state between each
  task, `FALSE` otherwise. It is recommended to only set
  `reset_options = TRUE` if `reset_packages` is also `TRUE` because
  packages sometimes rely on options they set at loading time. for this
  and other reasons, `reset_options` only resets options that were
  nonempty at the beginning of the task. If your task sets an entirely
  new option not already in
  [`options()`](https://rdrr.io/r/base/options.html), then
  `reset_options = TRUE` does not delete the option.

- garbage_collection:

  `TRUE` to run garbage collection after each task task, `FALSE` to
  skip.

- crashes_error:

  Deprecated on 2025-01-13 (`crew` version 0.10.2.9002).

- processes:

  Deprecated on 2025-08-27 (`crew` version 1.2.1.9009).

- r_arguments:

  Optional character vector of command line arguments to pass to
  `Rscript` (non-Windows) or `Rscript.exe` (Windows) when starting a
  worker. Example:
  `r_arguments = c("--vanilla", "--max-connections=32")`.

- crashes_max:

  In rare cases, a worker may exit unexpectedly before it completes its
  current task. If this happens, `pop()` returns a status of `"crash"`
  instead of `"error"` for the task. The controller does not
  automatically retry the task, but you can retry it manually by calling
  `push()` again and using the same task name as before. (However,
  `targets` pipelines running `crew` do automatically retry tasks whose
  workers crashed.)

  `crashes_max` is a non-negative integer, and it sets the maximum
  number of allowable consecutive crashes for a given task. If a task's
  worker crashes more than `crashes_max` times in a row, then `pop()`
  throws an error when it tries to return the results of the task.

- backup:

  An optional `crew` controller object, or `NULL` to omit. If supplied,
  the `backup` controller runs any pushed tasks that have already
  reached `crashes_max` consecutive crashes. Using `backup`, you can
  create a chain of controllers with different levels of resources (such
  as worker memory and CPUs) so that a task that fails on one controller
  can retry using incrementally more powerful workers. All controllers
  in a backup chain should be part of the same controller group (see
  [`crew_controller_group()`](https://wlandau.github.io/crew/reference/crew_controller_group.html))
  so you can call the group-level `pop()` and `collect()` methods to
  make sure you get results regardless of which controller actually
  ended up running the task.

  Limitations of `backup`: \* `crashes_max` needs to be positive in
  order for `backup` to be used. Otherwise, every task would always skip
  the current controller and go to `backup`. \* `backup` cannot be a
  controller group. It must be an ordinary controller.

- options_metrics:

  Either `NULL` to opt out of resource metric logging for workers, or an
  object from
  [`crew_options_metrics()`](https://wlandau.github.io/crew/reference/crew_options_metrics.html)
  to enable and configure resource metric logging for workers. For
  resource logging to run, the `autometric` R package version 0.1.0 or
  higher must be installed.

- options_aws_batch:

  List of options from
  [`crew_options_aws_batch()`](crew_options_aws_batch.md). The job
  definition and job queue must be specified in
  [`crew_options_aws_batch()`](crew_options_aws_batch.md).
  [`crew_options_aws_batch()`](crew_options_aws_batch.md) also allows
  you to request vCPUs, GPUs, and memory for the jobs.

- aws_batch_config:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_credentials:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_endpoint:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_region:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_job_definition:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_job_queue:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_share_identifier:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_scheduling_priority_override:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_parameters:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_container_overrides:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_node_overrides:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_retry_strategy:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_propagate_tags:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_timeout:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_tags:

  Deprecated. Use `options_aws_batch` instead.

- aws_batch_eks_properties_override:

  Deprecated. Use `options_aws_batch` instead.

## IAM policies

In order for the AWS Batch `crew` plugin to function properly, your IAM
policy needs permission to perform the `SubmitJob` and `TerminateJob`
AWS Batch API calls. For more information on AWS policies and
permissions, please visit
<https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html>.

## AWS arguments

The AWS Batch controller and launcher accept many arguments which start
with `"aws_batch_"`. These arguments are AWS-Batch-specific parameters
forwarded directly to the `submit_job()` method for the Batch client in
the `paws.compute` R package

For a full description of each argument, including its meaning and
format, please visit
<https://www.paws-r-sdk.com/docs/batch_submit_job/>. The upstream API
documentation is at
<https://docs.aws.amazon.com/batch/latest/APIReference/API_SubmitJob.html>
and the analogous CLI documentation is at
<https://docs.aws.amazon.com/cli/latest/reference/batch/submit-job.html>.

The actual argument names may vary slightly, depending on which : for
example, the `aws_batch_job_definition` argument of the `crew` AWS Batch
launcher/controller corresponds to the `jobDefinition` argument of the
web API and `paws.compute::batch()$submit_job()`, and both correspond to
the `--job-definition` argument of the CLI.

## Verbosity

Control verbosity with the `paws.log_level` global option in R. Set to 0
for minimum verbosity and 3 for maximum verbosity.

## See also

Other plugin_aws_batch:
[`crew_class_launcher_aws_batch`](crew_class_launcher_aws_batch.md),
[`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md)

## Examples

``` r
if (identical(Sys.getenv("CREW_EXAMPLES"), "true")) {
controller <- crew_controller_aws_batch(
  aws_batch_job_definition = "YOUR_JOB_DEFINITION_NAME",
  aws_batch_job_queue = "YOUR_JOB_QUEUE_NAME"
)
controller$start()
controller$push(name = "task", command = sqrt(4))
controller$wait()
controller$pop()$result
controller$terminate()
}
```
