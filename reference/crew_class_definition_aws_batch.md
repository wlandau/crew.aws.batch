# AWS Batch definition class

AWS Batch definition `R6` class

## Details

See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

## IAM policies

In order for the AWS Batch `crew` job definition class to function
properly, your IAM policy needs permission to perform the
`RegisterJobDefinition`, `DeregisterJobDefinition`, and
`DescribeJobDefinitions` AWS Batch API calls. For more information on
AWS policies and permissions, please visit
<https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html>.

## See also

Other definition:
[`crew_definition_aws_batch()`](crew_definition_aws_batch.md)

## Active bindings

- `job_queue`:

  See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

- `job_definition`:

  See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

- `log_group`:

  See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

- `config`:

  See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

- `credentials`:

  See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

- `endpoint`:

  See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

- `region`:

  See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

## Methods

### Public methods

- [`crew_class_definition_aws_batch$new()`](#method-crew_class_definition_aws_batch-new)

- [`crew_class_definition_aws_batch$validate()`](#method-crew_class_definition_aws_batch-validate)

- [`crew_class_definition_aws_batch$register()`](#method-crew_class_definition_aws_batch-register)

- [`crew_class_definition_aws_batch$deregister()`](#method-crew_class_definition_aws_batch-deregister)

- [`crew_class_definition_aws_batch$describe()`](#method-crew_class_definition_aws_batch-describe)

- [`crew_class_definition_aws_batch$submit()`](#method-crew_class_definition_aws_batch-submit)

------------------------------------------------------------------------

### Method `new()`

AWS Batch job definition constructor.

#### Usage

    crew_class_definition_aws_batch$new(
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

  See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

- `job_definition`:

  See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

- `log_group`:

  See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

- `config`:

  See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

- `credentials`:

  See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

- `endpoint`:

  See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

- `region`:

  See [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

#### Returns

AWS Batch job definition object.

------------------------------------------------------------------------

### Method `validate()`

Validate the object.

#### Usage

    crew_class_definition_aws_batch$validate()

#### Returns

`NULL` (invisibly). Throws an error if a field is invalid.

------------------------------------------------------------------------

### Method `register()`

Register a job definition.

#### Usage

    crew_class_definition_aws_batch$register(
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
    )

#### Arguments

- `image`:

  Character of length 1, Docker image used for each job. You can supply
  a path to an image in Docker Hub or the full URI of an image in an
  Amazon ECR repository.

- `platform_capabilities`:

  Optional character of length 1, either `"EC2"` to run on EC2 or
  `"FARGATE"` to run on Fargate.

- `memory_units`:

  Character of length 1, either `"gigabytes"` or `"mebibytes"` to set
  the units of the `memory` argument. `"gigabytes"` is simpler for EC2
  jobs, but Fargate has strict requirements about specifying exact
  amounts of mebibytes (MiB). for details, read
  <https://docs.aws.amazon.com/cli/latest/reference/batch/register-job-definition.html>
  \# nolint

- `memory`:

  Positive numeric of length 1, amount of memory to request for each
  job.

- `cpus`:

  Positive numeric of length 1, number of virtual CPUs to request for
  each job.

- `gpus`:

  Positive numeric of length 1, number of GPUs to request for each job.

- `seconds_timeout`:

  Optional positive numeric of length 1, number of seconds until a job
  times out.

- `scheduling_priority`:

  Optional nonnegative integer of length 1 between `0` and `9999`,
  priority of jobs. Jobs with higher-valued priorities are scheduled
  first. The priority only applies if the job queue has a fair share
  policy. Set to `NULL` to omit.

- `tags`:

  Optional character vector of tags.

- `propagate_tags`:

  Optional logical of length 1, whether to propagate tags from the job
  or definition to the ECS task.

- `parameters`:

  Optional character vector of key-value pairs designating parameters
  for job submission.

- `job_role_arn`:

  Character of length 1, Amazon resource name (ARN) of the job role.

- `execution_role_arn`:

  Character of length 1, Amazon resource name (ARN) of the execution
  role.

#### Details

The `register()` method registers a simple job definition using the job
definition name and log group originally supplied to
[`crew_definition_aws_batch()`](crew_definition_aws_batch.md). Job
definitions created with `$register()` are container-based and use the
AWS log driver. For more complicated kinds of jobs, we recommend
skipping `register()`: first call
<https://www.paws-r-sdk.com/docs/batch_register_job_definition/> to
register the job definition, then supply the job definition name to the
`job_definition` argument of
[`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

#### Returns

A one-row `tibble` with the job definition name, ARN, and revision
number of the registered job definition.

------------------------------------------------------------------------

### Method `deregister()`

Attempt to deregister a revision of the job definition.

#### Usage

    crew_class_definition_aws_batch$deregister(revision = NULL)

#### Arguments

- `revision`:

  Finite positive integer of length 1, optional revision number to
  deregister. If `NULL`, then only the highest revision number of the
  job definition is deregistered, if it exists.

#### Details

Attempt to deregister the job definition whose name was originally
supplied to the `job_definition` argument of
[`crew_definition_aws_batch()`](crew_definition_aws_batch.md).

#### Returns

`NULL` (invisibly).

------------------------------------------------------------------------

### Method `describe()`

Describe the revisions of the job definition.

#### Usage

    crew_class_definition_aws_batch$describe(revision = NULL, active = FALSE)

#### Arguments

- `revision`:

  Positive integer of length 1, optional revision number to describe.

- `active`:

  Logical of length 1, whether to filter on just the active job
  definition.

#### Returns

A `tibble` with job definition information. There is one row per
revision. Some fields may be nested lists.

------------------------------------------------------------------------

### Method `submit()`

Submit an AWS Batch job with the given job definition.

#### Usage

    crew_class_definition_aws_batch$submit(
      command = c("sleep", "300"),
      name = paste0("crew-aws-batch-job-", crew::crew_random_name()),
      cpus = NULL,
      gpus = NULL,
      memory_units = "gigabytes",
      memory = NULL,
      seconds_timeout = NULL,
      share_identifier = NULL,
      scheduling_priority_override = NULL,
      tags = NULL,
      propagate_tags = NULL,
      parameters = NULL
    )

#### Arguments

- `command`:

  Character vector with the command to submit for the job. Usually a
  Linux shell command with each term in its own character string.

- `name`:

  Character of length 1 with the job name.

- `cpus`:

  Positive numeric of length 1, number of virtual CPUs to request for
  each job.

- `gpus`:

  Positive numeric of length 1, number of GPUs to request for each job.

- `memory_units`:

  Character of length 1, either `"gigabytes"` or `"mebibytes"` to set
  the units of the `memory` argument. `"gigabytes"` is simpler for EC2
  jobs, but Fargate has strict requirements about specifying exact
  amounts of mebibytes (MiB). for details, read
  <https://docs.aws.amazon.com/cli/latest/reference/batch/register-job-definition.html>
  \# nolint

- `memory`:

  Positive numeric of length 1, amount of memory to request for each
  job.

- `seconds_timeout`:

  Optional positive numeric of length 1, number of seconds until a job
  times out.

- `share_identifier`:

  Character of length 1 with the share identifier of the job. Only
  applies if the job queue has a scheduling policy. Read the official
  AWS Batch documentation for details.

- `scheduling_priority_override`:

  Optional nonnegative integer of length between `0` and `9999`,
  priority of the job. This value overrides the priority in the job
  definition. Jobs with higher-valued priorities are scheduled first.
  The priority applies if the job queue has a fair share policy. Set to
  `NULL` to omit.

- `tags`:

  Optional character vector of tags.

- `propagate_tags`:

  Optional logical of length 1, whether to propagate tags from the job
  or definition to the ECS task.

- `parameters`:

  Optional character vector of key-value pairs designating parameters
  for job submission.

#### Details

This method uses the job queue and job definition that were supplied
through [`crew_definition_aws_batch()`](crew_definition_aws_batch.md).
Any jobs submitted this way are different from the `crew` workers that
the `crew` controller starts automatically using the AWS Batch launcher
plugin. You may use the `submit()` method in the definition for
different purposes such as testing.

#### Returns

A one-row `tibble` with the name, ID, and Amazon resource name (ARN) of
the job.
