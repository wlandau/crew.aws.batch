# AWS Batch options

Options for the AWS Batch controller.

## Usage

``` r
crew_options_aws_batch(
  job_definition = "example",
  job_queue = "example",
  cpus = NULL,
  gpus = NULL,
  memory = NULL,
  memory_units = "gigabytes",
  config = list(),
  credentials = list(),
  endpoint = NULL,
  region = NULL,
  share_identifier = NULL,
  scheduling_priority_override = NULL,
  parameters = NULL,
  container_overrides = NULL,
  node_overrides = NULL,
  retry_strategy = NULL,
  propagate_tags = NULL,
  timeout = NULL,
  tags = NULL,
  eks_properties_override = NULL,
  verbose = FALSE
)
```

## Arguments

- job_definition:

  Character of length 1, name of the AWS Batch job definition to use.
  There is no default for this argument, and a job definition must be
  created prior to running the controller. Please see
  <https://docs.aws.amazon.com/batch/> for details.

  To create a job definition, you will need to create a
  Docker-compatible image which can run R and `crew`. You may which to
  inherit from the images at
  <https://github.com/rocker-org/rocker-versioned2>.

- job_queue:

  Character of length 1, name of the AWS Batch job queue to use. There
  is no default for this argument, and a job queue must be created prior
  to running the controller. Please see
  <https://docs.aws.amazon.com/batch/> for details.

- cpus:

  Positive numeric scalar, number of virtual CPUs to request per job.
  Can be `NULL` to go with the defaults in the job definition. Ignored
  if `container_overrides` is not `NULL`.

- gpus:

  Positive numeric scalar, number of GPUs to request per job. Can be
  `NULL` to go with the defaults in the job definition. Ignored if
  `container_overrides` is not `NULL`.

- memory:

  Positive numeric scalar, amount of random access memory (RAM) to
  request per job. Choose the units of memory with the `memory_units`
  argument. Fargate instances can only be certain discrete values of
  mebibytes, so please choose `memory_units = "mebibytes"` in that case.
  The `memory` argument can be `NULL` to go with the defaults in the job
  definition. Ignored if `container_overrides` is not `NULL`.

- memory_units:

  Character string, units of memory of the `memory` argument. Can be
  `"gigabytes"` or `"mebibytes"`. Fargate instances can only be certain
  discrete values of mebibytes, so please choose
  `memory_units = "mebibytes"` in that case.

- config:

  Named list, `config` argument of
  [`paws.compute::batch()`](https://paws-r.r-universe.dev/paws.compute/reference/batch.html)
  with optional configuration details.

- credentials:

  Named list. `credentials` argument of
  [`paws.compute::batch()`](https://paws-r.r-universe.dev/paws.compute/reference/batch.html)
  with optional credentials (if not already provided through environment
  variables such as `AWS_ACCESS_KEY_ID`).

- endpoint:

  Character of length 1. `endpoint` argument of
  [`paws.compute::batch()`](https://paws-r.r-universe.dev/paws.compute/reference/batch.html)
  with the endpoint to send HTTP requests.

- region:

  Character of length 1. `region` argument of
  [`paws.compute::batch()`](https://paws-r.r-universe.dev/paws.compute/reference/batch.html)
  with an AWS region string such as `"us-east-2"`.

- share_identifier:

  `NULL` or character of length 1. For details, visit
  <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the "AWS
  arguments" sections of this help file.

- scheduling_priority_override:

  `NULL` or integer of length 1. For details, visit
  <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the "AWS
  arguments" sections of this help file.

- parameters:

  `NULL` or a nonempty list. For details, visit
  <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the "AWS
  arguments" sections of this help file.

- container_overrides:

  `NULL` or a nonempty named list of fields to override in the container
  specified in the job definition. Any overrides for the `command` field
  are ignored because `crew.aws.batch` needs to override the command to
  run the `crew` worker. For more details, visit
  <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the "AWS
  arguments" sections of this help file.

- node_overrides:

  `NULL` or a nonempty named list. For more details, visit
  <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the "AWS
  arguments" sections of this help file.

- retry_strategy:

  `NULL` or a nonempty named list. For more details, visit
  <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the "AWS
  arguments" sections of this help file.

- propagate_tags:

  `NULL` or a logical of length 1. For more details, visit
  <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the "AWS
  arguments" sections of this help file.

- timeout:

  `NULL` or a nonempty named list. For more details, visit
  <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the "AWS
  arguments" sections of this help file.

- tags:

  `NULL` or a nonempty named list. For more details, visit
  <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the "AWS
  arguments" sections of this help file.

- eks_properties_override:

  `NULL` or a nonempty named list. For more details, visit
  <https://www.paws-r-sdk.com/docs/batch_submit_job/> and the "AWS
  arguments" sections of this help file.

- verbose:

  `TRUE` to print informative console messages, `FALSE` otherwise.

## Value

A classed list of options for the controller.

## Retryable options

Retryable options are deprecated in `crew.aws.batch` as of 2025-01-27
(version `0.0.8`).
