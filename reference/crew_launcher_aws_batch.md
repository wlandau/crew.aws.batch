# Create an AWS Batch launcher object.

Create an `R6` AWS Batch launcher object.

## Usage

``` r
crew_launcher_aws_batch(
  name = NULL,
  workers = 1L,
  seconds_interval = 0.5,
  seconds_timeout = 60,
  seconds_launch = 1800,
  seconds_idle = 300,
  seconds_wall = Inf,
  tasks_max = Inf,
  tasks_timers = 0L,
  reset_globals = NULL,
  reset_packages = NULL,
  reset_options = NULL,
  garbage_collection = NULL,
  crashes_error = NULL,
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

- tasks_max:

  Maximum number of tasks that a worker will do before exiting. Also
  determines how often the controller auto-scales. See the Auto-scaling
  section for details.

- tasks_timers:

  Number of tasks to do before activating the timers for `seconds_idle`
  and `seconds_wall`. See the `timerstart` argument of
  [`mirai::daemon()`](https://mirai.r-lib.org/reference/daemon.html).

- reset_globals:

  Deprecated on 2025-05-30 (`crew` version 1.1.2.9004). Please use the
  `reset_globals` option of
  [`crew_controller()`](https://wlandau.github.io/crew/reference/crew_controller.html)
  instead.

- reset_packages:

  Deprecated on 2025-05-30 (`crew` version 1.1.2.9004). Please use the
  `reset_packages` option of
  [`crew_controller()`](https://wlandau.github.io/crew/reference/crew_controller.html)
  instead.

- reset_options:

  Deprecated on 2025-05-30 (`crew` version 1.1.2.9004). Please use the
  `reset_options` option of
  [`crew_controller()`](https://wlandau.github.io/crew/reference/crew_controller.html)
  instead.

- garbage_collection:

  Deprecated on 2025-05-30 (`crew` version 1.1.2.9004). Please use the
  `garbage_collection` option of
  [`crew_controller()`](https://wlandau.github.io/crew/reference/crew_controller.html)
  instead.

- crashes_error:

  Deprecated on 2025-01-13 (`crew` version 0.10.2.9002).

- tls:

  A TLS configuration object from
  [`crew_tls()`](https://wlandau.github.io/crew/reference/crew_tls.html).

- processes:

  Deprecated on 2025-08-27 (`crew` version 1.2.1.9009).

- r_arguments:

  Optional character vector of command line arguments to pass to
  `Rscript` (non-Windows) or `Rscript.exe` (Windows) when starting a
  worker. Example:
  `r_arguments = c("--vanilla", "--max-connections=32")`.

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

## Value

An `R6` AWS Batch launcher object.

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
[`crew_controller_aws_batch()`](crew_controller_aws_batch.md)
