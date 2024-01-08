# crew.aws.batch 0.0.2.9000 (development)



# crew.aws.batch 0.0.2

* Use `paws.common::paginate()` to get the full log of a job (#5). Requires `paws.common` >= 0.7.0 due to https://github.com/paws-r/paws/issues/721. 
* Rename `crew_aws_batch_monitor()` to `crew_monitor_aws_batch()` for syntactic consistency.
* Allow `terminate()` method of the monitor to terminate multiple job IDs. Also add a `cli` progress bar.

# crew.aws.batch 0.0.1

* First version.
