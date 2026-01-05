# Changelog

## crew.aws.batch 0.1.0.9000 (development)

## crew.aws.batch 0.1.0

CRAN release: 2025-09-15

- Remove `termiante_worker()`
  (<https://github.com/wlandau/crew/pull/236>).
- Support array jobs with the new `launch_workers()` (plural) method in
  launchers.
- Allow custom compute profiles.

## crew.aws.batch 0.0.12

- Add details to job status output in monitor.

## crew.aws.batch 0.0.11

CRAN release: 2025-06-09

- Compatibility with <https://github.com/wlandau/crew/issues/217>.

## crew.aws.batch 0.0.10

CRAN release: 2025-04-14

- Fix links.

## crew.aws.batch 0.0.9

- - Add a new `serialization` argument to the controller.

## crew.aws.batch 0.0.8

CRAN release: 2025-02-05

- Deprecate retryable options because `crew` 1.0.0 no longer supports
  them.
- In the monitor, return `POSIXct` time stamps for `created`, `started`,
  `stopped`, `timestamp` and `ingestion_time`.
- Print log messages from [`log()`](https://rdrr.io/r/base/Log.html)
  with [`writeLines()`](https://rdrr.io/r/base/writeLines.html).
- When `statusReason` cannot be shown, show an informative text entry
  instead of `NA`.

## crew.aws.batch 0.0.7

CRAN release: 2024-11-18

- Send both cancellation and termination requests to end jobs.
- Fix launcher bug/typo where parameters were supplied to container
  overrides.
- Add a new `all` argument to `terminate()` in the AWS Batch monitor.
- Add `r_arguments` to accept command line arguments to R.
- Support `options_metrics`.
- Reduce argument clutter with
  [`crew_options_aws_batch()`](../reference/crew_options_aws_batch.md).
  Supports direct inputs for CPUs, GPUs, and memory without having to
  specify a complicated `containerOverrides` list.
- Sanitize job names.
- Use `crashes_error` from `crew`.
- Make `cpus`, `gpus`, and `memory` retryable options.
- Change default `seconds_idle` to 300.

## crew.aws.batch 0.0.6

CRAN release: 2024-07-10

- Add a `retry_tasks` argument.

## crew.aws.batch 0.0.5

CRAN release: 2024-02-08

- Require `crew` \>= 0.8.0.
- Describe IAM policy requirements in the documentation.

## crew.aws.batch 0.0.4

CRAN release: 2024-01-10

- Move the `args_client()` and `args_submit()` launcher methods to the
  `private` list.
- Refactor testing infrastructure.
- Handle missing scheduling priorities so `definition$describe()` does
  not error out if the field is missing.

## crew.aws.batch 0.0.3

- Move all job definition management methods to their own class. (See
  [`crew_definition_aws_batch()`](../reference/crew_definition_aws_batch.md).)

## crew.aws.batch 0.0.2

- Use
  [`paws.common::paginate()`](https://paws-r.r-universe.dev/paws.common/reference/paginate.html)
  to get the full log of a job
  ([\#5](https://github.com/wlandau/crew.aws.batch/issues/5)). Requires
  `paws.common` \>= 0.7.0 due to
  <https://github.com/paws-r/paws/issues/721>.
- Rename `crew_aws_batch_monitor()` to
  [`crew_monitor_aws_batch()`](../reference/crew_monitor_aws_batch.md)
  for syntactic consistency.
- Allow `terminate()` method of the monitor to terminate multiple job
  IDs. Also add a `cli` progress bar.

## crew.aws.batch 0.0.1

CRAN release: 2023-12-13

- First version.
