# AWS Batch launcher class

AWS Batch launcher `R6` class

## Details

See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

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
[`crew_controller_aws_batch()`](crew_controller_aws_batch.md),
[`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md)

## Super class

[`crew::crew_class_launcher`](https://wlandau.github.io/crew/reference/crew_class_launcher.html)
-\> `crew_class_launcher_aws_batch`

## Active bindings

- `options_aws_batch`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

## Methods

### Public methods

- [`crew_class_launcher_aws_batch$new()`](#method-crew_class_launcher_aws_batch-new)

- [`crew_class_launcher_aws_batch$validate()`](#method-crew_class_launcher_aws_batch-validate)

- [`crew_class_launcher_aws_batch$launch_workers()`](#method-crew_class_launcher_aws_batch-launch_workers)

Inherited methods

- [`crew::crew_class_launcher$call()`](https://wlandau.github.io/crew/reference/crew_class_launcher.html#method-call)
- [`crew::crew_class_launcher$crashes()`](https://wlandau.github.io/crew/reference/crew_class_launcher.html#method-crashes)
- [`crew::crew_class_launcher$launch()`](https://wlandau.github.io/crew/reference/crew_class_launcher.html#method-launch)
- [`crew::crew_class_launcher$launch_worker()`](https://wlandau.github.io/crew/reference/crew_class_launcher.html#method-launch_worker)
- [`crew::crew_class_launcher$poll()`](https://wlandau.github.io/crew/reference/crew_class_launcher.html#method-poll)
- [`crew::crew_class_launcher$scale()`](https://wlandau.github.io/crew/reference/crew_class_launcher.html#method-scale)
- [`crew::crew_class_launcher$set_name()`](https://wlandau.github.io/crew/reference/crew_class_launcher.html#method-set_name)
- [`crew::crew_class_launcher$settings()`](https://wlandau.github.io/crew/reference/crew_class_launcher.html#method-settings)
- [`crew::crew_class_launcher$start()`](https://wlandau.github.io/crew/reference/crew_class_launcher.html#method-start)
- [`crew::crew_class_launcher$terminate()`](https://wlandau.github.io/crew/reference/crew_class_launcher.html#method-terminate)
- [`crew::crew_class_launcher$terminate_workers()`](https://wlandau.github.io/crew/reference/crew_class_launcher.html#method-terminate_workers)

------------------------------------------------------------------------

### Method `new()`

Abstract launcher constructor.

#### Usage

    crew_class_launcher_aws_batch$new(
      name = NULL,
      workers = NULL,
      seconds_interval = NULL,
      seconds_timeout = NULL,
      seconds_launch = NULL,
      seconds_idle = NULL,
      seconds_wall = NULL,
      tasks_max = NULL,
      tasks_timers = NULL,
      reset_globals = NULL,
      reset_packages = NULL,
      reset_options = NULL,
      garbage_collection = NULL,
      tls = NULL,
      processes = NULL,
      r_arguments = NULL,
      options_metrics = NULL,
      options_aws_batch = NULL
    )

#### Arguments

- `name`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `workers`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `seconds_interval`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `seconds_timeout`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `seconds_launch`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `seconds_idle`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `seconds_wall`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `tasks_max`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `tasks_timers`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `reset_globals`:

  Deprecated. See
  [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `reset_packages`:

  Deprecated. See
  [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `reset_options`:

  Deprecated. See
  [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `garbage_collection`:

  Deprecated. See
  [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `tls`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `processes`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `r_arguments`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `options_metrics`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

- `options_aws_batch`:

  See [`crew_launcher_aws_batch()`](crew_launcher_aws_batch.md).

#### Returns

An abstract launcher object.

------------------------------------------------------------------------

### Method `validate()`

Validate the launcher.

#### Usage

    crew_class_launcher_aws_batch$validate()

#### Returns

`NULL` (invisibly). Throws an error if a field is invalid.

------------------------------------------------------------------------

### Method `launch_workers()`

Launch a local process worker which will dial into a socket.

#### Usage

    crew_class_launcher_aws_batch$launch_workers(call, n)

#### Arguments

- `call`:

  Character string, a namespaced call to
  [`crew::crew_worker()`](https://wlandau.github.io/crew/reference/crew_worker.html)
  which will run in the worker and accept tasks.

- `n`:

  Integer of length 1, number of workers to launch in the array job for
  the current round of auto-scaling.

#### Details

The `call` argument is R code that will run to initiate the worker.

#### Returns

A handle object to allow the termination of the worker later on.
