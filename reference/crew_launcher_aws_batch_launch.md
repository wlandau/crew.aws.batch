# Submit an AWS Batch job.

Not a user-side function. For internal use only.

## Usage

``` r
crew_launcher_aws_batch_launch(args_client, args_submit)
```

## Arguments

- args_client:

  Named list of arguments to
  [`paws.compute::batch()`](https://paws-r.r-universe.dev/paws.compute/reference/batch.html).

- args_submit:

  Named list of arguments to `paws.compute::batch()$submit_job()`.

## Value

HTTP response from submitting the job.

## Details

This utility is its own separate exported function specific to the
launcher and not shared with the job definition or monitor classes. It
generates the
[`paws.compute::batch()`](https://paws-r.r-universe.dev/paws.compute/reference/batch.html)
client within itself instead of a method inside the class. This is all
because it needs to run on a separate local worker process and it needs
to accept exportable arguments.
