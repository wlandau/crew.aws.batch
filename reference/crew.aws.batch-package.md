# crew.aws.batch: a crew launcher plugin for AWS Batch

In computationally demanding analysis projects, statisticians and data
scientists asynchronously deploy long-running tasks to distributed
systems, ranging from traditional clusters to cloud services. The
`crew.aws.batch` package extends the
[`mirai`](https://github.com/r-lib/mirai)-powered
[`crew`](https://wlandau.github.io) package with worker launcher plugins
for AWS Batch. Inspiration also comes from packages
[`mirai`](https://github.com/r-lib/mirai),
[`future`](https://future.futureverse.org/),
[`rrq`](https://mrc-ide.github.io/rrq/),
[`clustermq`](https://mschubert.github.io/clustermq/), and
[`batchtools`](https://batchtools.mlr-org.com).
