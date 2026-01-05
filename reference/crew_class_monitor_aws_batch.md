# AWS Batch monitor class

AWS Batch monitor `R6` class

## Details

See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

## IAM policies

In order for the AWS Batch `crew` monitor class to function properly,
your IAM policy needs permission to perform the `SubmitJob`,
`TerminateJob`, `ListJobs`, and `DescribeJobs` AWS Batch API calls. In
addition, to download CloudWatch logs with the
[`log()`](https://rdrr.io/r/base/Log.html) method, your IAM policy also
needs permission to perform the `GetLogEvents` CloudWatch logs API call.
For more information on AWS policies and permissions, please visit
<https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html>.

## See also

Other monitor: [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md)

## Active bindings

- `job_queue`:

  See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

- `job_definition`:

  See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

- `log_group`:

  See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

- `config`:

  See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

- `credentials`:

  See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

- `endpoint`:

  See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

- `region`:

  See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

## Methods

### Public methods

- [`crew_class_monitor_aws_batch$new()`](#method-crew_class_monitor_aws_batch-new)

- [`crew_class_monitor_aws_batch$validate()`](#method-crew_class_monitor_aws_batch-validate)

- [`crew_class_monitor_aws_batch$terminate()`](#method-crew_class_monitor_aws_batch-terminate)

- [`crew_class_monitor_aws_batch$status()`](#method-crew_class_monitor_aws_batch-status)

- [`crew_class_monitor_aws_batch$log()`](#method-crew_class_monitor_aws_batch-log)

- [`crew_class_monitor_aws_batch$jobs()`](#method-crew_class_monitor_aws_batch-jobs)

- [`crew_class_monitor_aws_batch$active()`](#method-crew_class_monitor_aws_batch-active)

- [`crew_class_monitor_aws_batch$inactive()`](#method-crew_class_monitor_aws_batch-inactive)

- [`crew_class_monitor_aws_batch$submitted()`](#method-crew_class_monitor_aws_batch-submitted)

- [`crew_class_monitor_aws_batch$pending()`](#method-crew_class_monitor_aws_batch-pending)

- [`crew_class_monitor_aws_batch$runnable()`](#method-crew_class_monitor_aws_batch-runnable)

- [`crew_class_monitor_aws_batch$starting()`](#method-crew_class_monitor_aws_batch-starting)

- [`crew_class_monitor_aws_batch$running()`](#method-crew_class_monitor_aws_batch-running)

- [`crew_class_monitor_aws_batch$succeeded()`](#method-crew_class_monitor_aws_batch-succeeded)

- [`crew_class_monitor_aws_batch$failed()`](#method-crew_class_monitor_aws_batch-failed)

------------------------------------------------------------------------

### Method `new()`

AWS Batch job definition constructor.

#### Usage

    crew_class_monitor_aws_batch$new(
      job_queue = NULL,
      job_definition = NULL,
      log_group = NULL,
      config = NULL,
      credentials = NULL,
      endpoint = NULL,
      region = NULL
    )

#### Arguments

- `job_queue`:

  See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

- `job_definition`:

  See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

- `log_group`:

  See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

- `config`:

  See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

- `credentials`:

  See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

- `endpoint`:

  See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

- `region`:

  See [`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

#### Returns

AWS Batch job definition object.

------------------------------------------------------------------------

### Method `validate()`

Validate the object.

#### Usage

    crew_class_monitor_aws_batch$validate()

#### Returns

`NULL` (invisibly). Throws an error if a field is invalid.

------------------------------------------------------------------------

### Method `terminate()`

Terminate one or more AWS Batch jobs.

#### Usage

    crew_class_monitor_aws_batch$terminate(
      ids = NULL,
      all = FALSE,
      reason = "cancelled/terminated by crew.aws.batch monitor",
      verbose = TRUE
    )

#### Arguments

- `ids`:

  Character vector with the IDs of the AWS Batch jobs to terminate.
  Leave as `NULL` if `all` is `TRUE`.

- `all`:

  `TRUE` to terminate all jobs belonging to the previously specified job
  definition. `FALSE` to terminate only the job IDs given in the `ids`
  argument.

- `reason`:

  Character of length 1, natural language explaining the reason the job
  was terminated.

- `verbose`:

  Logical of length 1, whether to show a progress bar if the R process
  is interactive and `length(ids)` is greater than 1.

#### Returns

`NULL` (invisibly).

------------------------------------------------------------------------

### Method `status()`

Get the status of a single job

#### Usage

    crew_class_monitor_aws_batch$status(id)

#### Arguments

- `id`:

  Character of length 1, job ID. This is different from the
  user-supplied job name.

#### Returns

A one-row `tibble` with information about the job.

------------------------------------------------------------------------

### Method [`log()`](https://rdrr.io/r/base/Log.html)

Get the CloudWatch log of a job.

#### Usage

    crew_class_monitor_aws_batch$log(id, path = stdout(), start_from_head = FALSE)

#### Arguments

- `id`:

  Character of length 1, job ID. This is different from the
  user-supplied job name.

- `path`:

  Character string or stream (e.g.
  [`stdout()`](https://rdrr.io/r/base/showConnections.html)), file path
  or connection passed to the `con` argument of
  [`writeLines()`](https://rdrr.io/r/base/writeLines.html) to print the
  log messages. Set to
  [`nullfile()`](https://rdrr.io/r/base/showConnections.html) to
  suppress output (and use the invisibly returned `tibble` object
  instead).

- `start_from_head`:

  Logical of length 1, whether to print earlier log events before later
  ones.

#### Details

This method assumes the job has log driver `"awslogs"` (specifying AWS
CloudWatch) and that the log group is the one prespecified in the
`log_group` argument of
[`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md). This method
cannot use other log drivers such as Splunk, and it will fail if the log
group is wrong or missing.

#### Returns

[`log()`](https://rdrr.io/r/base/Log.html) invisibly returns a `tibble`
with log information and writes the messages to the stream or path given
by the `path` argument.

------------------------------------------------------------------------

### Method `jobs()`

List all the jobs in the given job queue with the given job definition.

#### Usage

    crew_class_monitor_aws_batch$jobs(
      status = c("submitted", "pending", "runnable", "starting", "running", "succeeded",
        "failed")
    )

#### Arguments

- `status`:

  Character vector of job states. Results are limited to these job
  states.

#### Details

The output only includes jobs under the job queue and job definition
that were supplied through
[`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

#### Returns

A `tibble` with one row per job and columns with job information.

------------------------------------------------------------------------

### Method `active()`

List active jobs: submitted, pending, runnable, starting, or running
(not succeeded or failed).

#### Usage

    crew_class_monitor_aws_batch$active()

#### Details

The output only includes jobs under the job queue and job definition
that were supplied through
[`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

#### Returns

A `tibble` with one row per job and columns with job information.

------------------------------------------------------------------------

### Method `inactive()`

List inactive jobs: ones whose status is succeeded or failed (not
submitted, pending, runnable, starting, or running).

#### Usage

    crew_class_monitor_aws_batch$inactive()

#### Details

The output only includes jobs under the job queue and job definition
that were supplied through
[`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

#### Returns

A `tibble` with one row per job and columns with job information.

------------------------------------------------------------------------

### Method `submitted()`

List jobs whose status is `"submitted"`.

#### Usage

    crew_class_monitor_aws_batch$submitted()

#### Details

The output only includes jobs under the job queue and job definition
that were supplied through
[`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

#### Returns

A `tibble` with one row per job and columns with job information.

------------------------------------------------------------------------

### Method `pending()`

List jobs whose status is `"pending"`.

#### Usage

    crew_class_monitor_aws_batch$pending()

#### Details

The output only includes jobs under the job queue and job definition
that were supplied through
[`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

#### Returns

A `tibble` with one row per job and columns with job information.

------------------------------------------------------------------------

### Method `runnable()`

List jobs whose status is `"runnable"`.

#### Usage

    crew_class_monitor_aws_batch$runnable()

#### Details

The output only includes jobs under the job queue and job definition
that were supplied through
[`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

#### Returns

A `tibble` with one row per job and columns with job information.

------------------------------------------------------------------------

### Method `starting()`

List jobs whose status is `"starting"`.

#### Usage

    crew_class_monitor_aws_batch$starting()

#### Details

The output only includes jobs under the job queue and job definition
that were supplied through
[`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

#### Returns

A `tibble` with one row per job and columns with job information.

------------------------------------------------------------------------

### Method `running()`

List jobs whose status is `"running"`.

#### Usage

    crew_class_monitor_aws_batch$running()

#### Details

The output only includes jobs under the job queue and job definition
that were supplied through
[`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

#### Returns

A `tibble` with one row per job and columns with job information.

------------------------------------------------------------------------

### Method `succeeded()`

List jobs whose status is `"succeeded"`.

#### Usage

    crew_class_monitor_aws_batch$succeeded()

#### Details

The output only includes jobs under the job queue and job definition
that were supplied through
[`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

#### Returns

A `tibble` with one row per job and columns with job information.

------------------------------------------------------------------------

### Method `failed()`

List jobs whose status is `"failed"`.

#### Usage

    crew_class_monitor_aws_batch$failed()

#### Details

The output only includes jobs under the job queue and job definition
that were supplied through
[`crew_monitor_aws_batch()`](crew_monitor_aws_batch.md).

#### Returns

A `tibble` with one row per job and columns with job information.
