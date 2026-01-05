# Create an AWS Batch monitor object.

Create an `R6` object to list, inspect, and terminate AWS Batch jobs.

## Usage

``` r
crew_monitor_aws_batch(
  job_queue,
  job_definition,
  log_group = "/aws/batch/job",
  config = NULL,
  credentials = NULL,
  endpoint = NULL,
  region = NULL
)
```

## Arguments

- job_queue:

  Character vector of names of AWS Batch job queues. As of
  `crew.aws.batch` version 0.0.8 and above, you can supply more than one
  job queue. Methods like `jobs()` and `active()` will query all the job
  queues given.

- job_definition:

  Character string, name of the AWS Batch job definition.

- log_group:

  Character of length 1, AWS Batch CloudWatch log group to get job logs.
  The default log group is often `"/aws/batch/job"`, but not always. It
  is not easy to get the log group of an active job or job definition,
  so if you have a non-default log group and you do not know its name,
  please consult your system administrator.

- config:

  Optional named list, `config` argument of
  [`paws.compute::batch()`](https://paws-r.r-universe.dev/paws.compute/reference/batch.html)
  with optional configuration details.

- credentials:

  Optional named list. `credentials` argument of
  [`paws.compute::batch()`](https://paws-r.r-universe.dev/paws.compute/reference/batch.html)
  with optional credentials (if not already provided through environment
  variables such as `AWS_ACCESS_KEY_ID`).

- endpoint:

  Optional character of length 1. `endpoint` argument of
  [`paws.compute::batch()`](https://paws-r.r-universe.dev/paws.compute/reference/batch.html)
  with the endpoint to send HTTP requests.

- region:

  Character of length 1. `region` argument of
  [`paws.compute::batch()`](https://paws-r.r-universe.dev/paws.compute/reference/batch.html)
  with an AWS region string such as `"us-east-2"`. Serves as the region
  for both AWS Batch and CloudWatch. Tries to default to
  `paws.common::get_config()$region`, then to `Sys.getenv("AWS_REGION")`
  if unsuccessful, then `Sys.getenv("AWS_REGION")`, then
  `Sys.getenv("AWS_DEFAULT_REGION")`.

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

Other monitor:
[`crew_class_monitor_aws_batch`](crew_class_monitor_aws_batch.md)
