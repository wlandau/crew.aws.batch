# crew.aws.batch 0.0.8

* Deprecate retryable options because `crew` 1.0.0 no longer supports them.
* In the monitor, return `POSIXct` time stamps for `created`, `started`, `stopped`, `timestamp` and `ingestion_time`.
* Print log messages from `log()` with `writeLines()`.
* When `statusReason` cannot be shown, show an informative text entry instead of `NA`.

# crew.aws.batch 0.0.7

* Send both cancellation and termination requests to end jobs.
* Fix launcher bug/typo where parameters were supplied to container overrides.
* Add a new `all` argument to `terminate()` in the AWS Batch monitor.
* Add `r_arguments` to accept command line arguments to R.
* Support `options_metrics`.
* Reduce argument clutter with `crew_options_aws_batch()`. Supports direct inputs for CPUs, GPUs, and memory without having to specify a complicated `containerOverrides` list.
* Sanitize job names.
* Use `crashes_error` from `crew`.
* Make `cpus`, `gpus`, and `memory` retryable options.
* Change default `seconds_idle` to 300.

# crew.aws.batch 0.0.6

* Add a `retry_tasks` argument.

# crew.aws.batch 0.0.5

* Require `crew` >= 0.8.0.
* Describe IAM policy requirements in the documentation.

# crew.aws.batch 0.0.4

* Move the `args_client()` and `args_submit()` launcher methods to the `private` list.
* Refactor testing infrastructure.
* Handle missing scheduling priorities so `definition$describe()` does not error out if the field is missing.

# crew.aws.batch 0.0.3

* Move all job definition management methods to their own class. (See `crew_definition_aws_batch()`.)

# crew.aws.batch 0.0.2

* Use `paws.common::paginate()` to get the full log of a job (#5). Requires `paws.common` >= 0.7.0 due to https://github.com/paws-r/paws/issues/721. 
* Rename `crew_aws_batch_monitor()` to `crew_monitor_aws_batch()` for syntactic consistency.
* Allow `terminate()` method of the monitor to terminate multiple job IDs. Also add a `cli` progress bar.

# crew.aws.batch 0.0.1

* First version.
