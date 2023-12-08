
# crew.aws.batch: a crew launcher plugin for AWS Batch <img src='man/figures/logo-readme.png' align="right" height="139"/>

<!--[![CRAN](https://www.r-pkg.org/badges/version/crew.aws.batch)](https://CRAN.R-project.org/package=crew.aws.batch)-->

[![status](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#Active)
[![check](https://github.com/wlandau/crew.aws.batch/workflows/check/badge.svg)](https://github.com/wlandau/crew.aws.batch/actions?query=workflow%3Acheck)
[![codecov](https://codecov.io/gh/wlandau/crew.aws.batch/branch/main/graph/badge.svg)](https://app.codecov.io/gh/wlandau/crew.aws.batch)
[![lint](https://github.com/wlandau/crew.aws.batch/workflows/lint/badge.svg)](https://github.com/wlandau/crew.aws.batch/actions?query=workflow%3Alint)

In computationally demanding analysis projects, statisticians and data
scientists asynchronously deploy long-running tasks to distributed
systems, ranging from traditional clusters to cloud services. The
`crew.aws.batch` package extends the
[`mirai`](https://github.com/shikokuchuo/mirai)-powered ‘crew’ package
with a worker launcher plugin for [AWS
Batch](https://aws.amazon.com/batch/). Inspiration also comes from
packages [`mirai`](https://github.com/shikokuchuo/mirai),
[`future`](https://future.futureverse.org/),
[`rrq`](https://mrc-ide.github.io/rrq/),
[`clustermq`](https://mschubert.github.io/clustermq/), and
[`batchtools`](https://mllg.github.io/batchtools/).

# Installation

| Type        | Source     | Command                                                                        |
|-------------|------------|--------------------------------------------------------------------------------|
| Release     | CRAN       | `install.packages("crew.aws.batch")`                                           |
| Development | GitHub     | `remotes::install_github("wlandau/crew.aws.batch")`                            |
| Development | R-universe | `install.packages("crew.aws.batch", repos = "https://wlandau.r-universe.dev")` |

# Documentation

Please see <https://wlandau.github.io/crew.aws.batch/> for
documentation, including a full function reference and usage tutorial.

# Prerequisites

`crew.aws.batch` launches [AWS Batch](https://aws.amazon.com/batch/)
jobs to run [`crew`](https://wlandau.github.io/crew/) workers. This
comes with a set of special requirements:

1.  Understand [AWS Batch](https://aws.amazon.com/batch/) and its
    [official documentation](https://aws.amazon.com/batch/).
2.  Your [job
    definitions](https://docs.aws.amazon.com/batch/latest/userguide/job_definitions.html)
    must each have [Docker](https://www.docker.com/)-compatible
    container image with R and `crew.aws.batch` installed. You may wish
    to inherit from an existing
    [rocker](https://github.com/rocker-org/rocker-versioned2) image.
3.  In the [compute
    environment](https://docs.aws.amazon.com/batch/latest/userguide/compute_environments.html),
    the [security
    group](https://docs.aws.amazon.com/vpc/latest/userguide/security-groups.html)
    must permit all inbound and outbound TCP traffic within itself.[^1]
    The controller and the workers must run in this security group so
    they can communicate within the firewalled local network.[^2] If
    your security group ID is `sg-00000` and belongs to
    [VPC](https://aws.amazon.com/vpc/) `vpc-00000`, then your inbound
    and outbound rules may look something like this:

![](./man/figures/inbound.png)

![](./man/figures/outbound.png)

``` r
client <- paws.compute::ec2()
groups <- client$describe_security_groups(GroupIds = "sg-00000")
str(groups$SecurityGroups[[1L]])
#> List of 8
#>  $ Description        : chr "Allow TCP traffic on ephemeral ports"
#>  $ GroupName          : chr "self-pointing-group"
#>  $ IpPermissions      :List of 1
#>   ..$ :List of 7
#>   .. ..$ FromPort        : num 1024
#>   .. ..$ IpProtocol      : chr "tcp"
#>   .. ..$ IpRanges        : list()
#>   .. ..$ Ipv6Ranges      : list()
#>   .. ..$ PrefixListIds   : list()
#>   .. ..$ ToPort          : num 65535
#>   .. ..$ UserIdGroupPairs:List of 1
#>   .. .. ..$ :List of 7
#>   .. .. .. ..$ Description           : chr "Accept traffic from other jobs in group."
#>   .. .. .. ..$ GroupId               : chr "sg-00000"
#>   .. .. .. ..$ GroupName             : chr(0)
#>   .. .. .. ..$ PeeringStatus         : chr(0)
#>   .. .. .. ..$ UserId                : chr "CENSORED"
#>   .. .. .. ..$ VpcId                 : chr(0)
#>   .. .. .. ..$ VpcPeeringConnectionId: chr(0)
#>  $ OwnerId            : chr "CENSORED"
#>  $ GroupId            : chr "sg-00000"
#>  $ IpPermissionsEgress:List of 1
#>   ..$ :List of 7
#>   .. ..$ FromPort        : num 1024
#>   .. ..$ IpProtocol      : chr "tcp"
#>   .. ..$ IpRanges        : list()
#>   .. ..$ Ipv6Ranges      : list()
#>   .. ..$ PrefixListIds   : list()
#>   .. ..$ ToPort          : num 65535
#>   .. ..$ UserIdGroupPairs:List of 1
#>   .. .. ..$ :List of 7
#>   .. .. .. ..$ Description           : chr "Allow traffic to other jobs in group."
#>   .. .. .. ..$ GroupId               : chr "sg-00000"
#>   .. .. .. ..$ GroupName             : chr(0)
#>   .. .. .. ..$ PeeringStatus         : chr(0)
#>   .. .. .. ..$ UserId                : chr "CENSORED"
#>   .. .. .. ..$ VpcId                 : chr(0)
#>   .. .. .. ..$ VpcPeeringConnectionId: chr(0)
#>  $ Tags               : list()
#>  $ VpcId              : chr "vpc-00000"
```

# Job management

With `crew.aws.batch`, your `crew` controller automatically submits jobs
to AWS Batch. These jobs may fail or linger for any number of reasons,
which could impede work and increase costs. So before you use
`crew_controller_aws_batch()`, please learn how to monitor and terminate
AWS Batch jobs manually.

`crew.aws.batch` defines a “monitor” class to help you take control of
jobs and job definitions. Create a monitor object with
`crew_aws_batch_monitor()`. You will need to supply a job definition
name and a job queue name.

``` r
monitor <- crew_aws_batch_monitor(
  job_definition = "YOUR_JOB_DEFINITION_NAME",
  job_queue = "YOUR_JOB_QUEUE_NAME"
)
```

The job definition may or may not exist at this point. If it does not
exist, you can register with `register()`, an oversimplified
limited-scope method which creates container-based job definitions with
the `"awslogs"` log driver (for CloudWatch).[^3] Below, your container
image can be as simple as a Docker Hub identifier (like
`"alpine:latest:`) or a full URI of an ECR image.[^4]

``` r
monitor$register(
  image = "AWS_ACCOUNT_ID.dkr.ecr.AWS_REGION.amazonaws.com/ECR_REPOSITORY_NAME:IMAGE_TAG",
  platform_capabilities = "EC2",
  memory_units = "gigabytes",
  memory = 8,
  cpus = 2
)
```

You can submit individual AWS Batch jobs to test your computing
environment.

``` r
job1 <- monitor$submit(name = "job1", command = c("echo", "hello\nworld"))
job2 <- monitor$submit(name = "job2", command = c("echo", "job\nsubmitted"))
job2
#> # A tibble: 1 × 3
#>   name  id                                   arn                       
#>   <chr> <chr>                                <chr>                     
#> 1 job2  c38d55ad-4a86-4371-9994-6ea8882f5726 arn:aws:batch:us-east-2:0…
```

Method `status()` checks the status of an individual job.

``` r
monitor$status(id = job2$id)
#> # A tibble: 1 × 8
#>   name  id                arn   status   reason created started stopped
#>   <chr> <chr>             <chr> <chr>    <chr>    <dbl>   <dbl>   <dbl>
#> 1 job2  c38d55ad-4a86-43… arn:… runnable NA     1.70e12      NA      NA
```

The `jobs()` method gets the status of all the jobs within the job queue
and job definition you originally supplied to
`crew_aws_batch_monitor()`. This may include many more jobs than the
ones you submitted during the life cycle of the current `monitor`
object.

``` r
monitor$jobs()
#> # A tibble: 2 × 8
#>   name  id                arn   status    reason created started stopped
#>   <chr> <chr>             <chr> <chr>     <chr>    <dbl>   <dbl>   <dbl>
#> 1 job1  653df636-ac74-43… arn:… succeeded Essen… 1.70e12 1.70e12 1.70e12
#> 2 job2  c38d55ad-4a86-43… arn:… runnable  NA     1.70e12      NA      NA
```

The [job
state](https://docs.aws.amazon.com/batch/latest/userguide/job_states.html)
can be `"submitted"`, `"pending"`, `"runnable"`, `"starting"`,
`"running"`, `"succeeded"`, or `"failed"`. The monitor has a method for
each job state to get only the jobs with that state.

``` r
monitor$succeeded()
#> # A tibble: 1 × 8
#>   name  id                arn   status    reason created started stopped
#>   <chr> <chr>             <chr> <chr>     <chr>    <dbl>   <dbl>   <dbl>
#> 1 job1  653df636-ac74-43… arn:… succeeded NA     1.70e12 1.70e12 1.70e12
```

In addition, there is an `active()` method for just states
`"submitted"`, `"pending"`, `"runnable"`, `"starting"`, and `"running"`,
and there is an `inactive()` method for just the `"succeeded"` and
`"failed"` states.

``` r
monitor$inactive()
#> # A tibble: 1 × 8
#>   name  id                arn   status    reason created started stopped
#>   <chr> <chr>             <chr> <chr>     <chr>    <dbl>   <dbl>   <dbl>
#> 1 job1  653df636-ac74-43… arn:… succeeded NA     1.70e12 1.70e12 1.70e12
```

To terminate a job, use the `terminate()` method. This has the effect of
both canceling and terminating the job, although you may not see the
change right away if the job is currently `"runnable"`. Manually
terminated jobs are listed as failed.

``` r
monitor$terminate(id = job2$id)
```

To get the CloudWatch logs of a job, use the `log()` method. This method
returns a `tibble` with the log messages and numeric timestamps.

``` r
log <- monitor$log(id = job1$id)
log
#> # A tibble: 2 × 3
#>   message     timestamp ingestion_time
#>   <chr>           <dbl>          <dbl>
#> 1 hello   1702068378163  1702068378245
#> 2 world   1702068378163  1702068378245
```

If the log messages are too long to conveniently view in the `tibble`,
you can print them to your screen with `cat()` or `writeLines()`.

``` r
writeLines(log$message)
#> hello
#> world
```

# Using `crew` with AWS Batch workers

To start using `crew.aws.batch` in earnest, first create a controller
object. Also supply the names of your job queue and job definition, as
well as any optional flags and settings you may need. If you do not
already have a job definition, the “monitor” object above can help you
create one (see above).

``` r
library(crew.aws.batch)
controller <- crew_controller_aws_batch(
  name = "my_workflow", # for informative job names
  workers = 16,
  tasks_max = 2, # to avoid reaching wall time limits
  seconds_launch = 600, # to allow a 10-minute startup window
  seconds_idle = 60, # to release resources when they are not needed
  processes = NULL, # See the "Asynchronous worker management" section below.
  aws_batch_job_definition = "YOUR_JOB_DEFINITION_NAME",
  aws_batch_job_queue = "YOUR_JOB_QUEUE_NAME"
)
controller$start()
```

At this point, usage is exactly the same as basic
[`crew`](https://wlandau.github.io/crew). The `push()` method submits
tasks and auto-scales [AWS Batch](https://aws.amazon.com/batch/) workers
to meet demand.

``` r
controller$push(name = "do work", command = do_work())
```

The `pop()` method retrieves available tasks.

``` r
controller$pop()
#> # A tibble: 1 × 11
#>   name         command result seconds   seed error trace warni…¹ launc…² worker insta…³
#>   <chr>        <chr>   <list>   <dbl>  <int> <chr> <chr> <chr>   <chr>    <int> <chr>  
#> 1 do work   … do_work… <int>        0 1.56e8 NA    NA    NA      79e71c…      1 7686b2…
#> # … with abbreviated variable names ¹​warnings, ²​launcher, ³​instance
```

Remember to terminate the controller when you are done.

``` r
controller$terminate()
```

# Asynchronous worker management

HTTP requests to submit and terminate jobs may take up to 1 or 2
seconds, and this overhead may be burdensome if there are many workers.
To run these requests asynchronously, set the `processes` argument of
`crew_controller_aws_batch()` to the number of local `mirai` daemons you
want to process the requests. These processes will start on
`controller$start()` and end on `controller$terminate()` or when your
local R session ends. `controller$launcher$async$errors()` shows the
most recent error messages generated on launch or termination for all
workers.

# Troubleshooting

`processes = NULL` disables async and makes launch/termination errors
immediate and easier to see. You may also wish to set
`options(paws.log_level = 3L)` to increase the verbosity of `paws`
messages.

# Thanks

- [Charlie Gao](https://github.com/shikokuchuo) created
  [`mirai`](https://github.com/shikokuchuo/mirai) and
  [`nanonext`](https://github.com/shikokuchuo/nanonext) and graciously
  accommodated the complicated and demanding feature requests that made
  `crew` and its ecosystem possible.
- Thanks to [Henrik Bengtsson](https://github.com/HenrikBengtsson),
  [David Kretch](https://github.com/davidkretch), [Adam
  Banker](https://github.com/adambanker), and [Michael
  Schubert](https://github.com/mschubert) for edifying conversations
  about cloud computing in R.

# Code of Conduct

Please note that the `crew` project is released with a [Contributor Code
of
Conduct](https://github.com/wlandau/crew/blob/main/CODE_OF_CONDUCT.md).
By contributing to this project, you agree to abide by its terms.

# Citation

``` r
citation("crew.aws.batch")
To cite package 'crew.aws.batch' in publications use:

  Landau WM (????). _crew.aws.batch: A Crew Launcher Plugin for AWS
  Batch_. R package version 0.0.0.9001,
  https://github.com/wlandau/crew.aws.batch,
  <https://wlandau.github.io/crew.aws.batch/>.

A BibTeX entry for LaTeX users is

  @Manual{,
    title = {crew.aws.batch: A Crew Launcher Plugin for AWS Batch},
    author = {William Michael Landau},
    note = {R package version 0.0.0.9001, 
https://github.com/wlandau/crew.aws.batch},
    url = {https://wlandau.github.io/crew.aws.batch/},
  }
```

[^1]: If you already know the TCP port you will supply to `port`
    argument of `crew_controller_aws_batch()`, you can restrict the port
    range to only use that port number.

[^2]: Please read about the
    [risks](https://wlandau.github.io/crew/articles/risks.html) and keep
    TLS encryption turned on (default:
    `tls = crew_tls(mode = "automatic")`). Please understand and comply
    with all the security policies of your organization.

[^3]: The log group supplied to `crew_aws_batch_monitor()` must be
    valid. The default is `"/aws/batch/log"`, which may not exist if
    your system administrator has a custom logging policy.

[^4]: For the `crew` controller, you will definitely want an image with
    R and `crew` installed. For the purposes of testing the monitor,
    `"alpine:latest"` will work.
