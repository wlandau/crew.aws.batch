# Create an AWS Batch job definition object.

Create an `R6` object to manage a job definition for AWS Batch jobs.

## Usage

``` r
crew_definition_aws_batch(
  job_queue,
  job_definition = paste0("crew-aws-batch-job-definition-", crew::crew_random_name()),
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

  Character of length 1, name of the AWS Batch job definition. The job
  definition might or might not exist at the time
  `crew_definition_aws_batch()` is called. Either way is fine.

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

## Value

An `R6` job definition object.

## IAM policies

In order for the AWS Batch `crew` job definition class to function
properly, your IAM policy needs permission to perform the
`RegisterJobDefinition`, `DeregisterJobDefinition`, and
`DescribeJobDefinitions` AWS Batch API calls. For more information on
AWS policies and permissions, please visit
<https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html>.

## See also

Other definition:
[`crew_class_definition_aws_batch`](crew_class_definition_aws_batch.md)
