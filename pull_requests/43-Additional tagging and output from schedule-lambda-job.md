# Additional tagging and output from schedule-lambda-job

**kevingunn-wk** commented *Apr 23, 2020*

Added tagging for a few more resources that support it:
- aws_securit_group
- aws_iam_role
- aws_cloudwatch_event_rule

Also thought it might be helpful to add some output to the `schedule-lambda-job` module. This might be particularly helpful when this is coupled with the lambda module.

Using [gurntwork-io/package-lambda/examples/scheduled-lambda-job](https://github.com/gruntwork-io/package-lambda/tree/master/examples/scheduled-lambda-job) as an example, adding the outputs will allow users to run `terragrunt output` and determine whether or not the lambda is scheduled.
<br />
***


**brikis98** commented *Apr 27, 2020*

Tests passed! Merging now, thanks!
***

**brikis98** commented *Apr 27, 2020*

https://github.com/gruntwork-io/package-lambda/releases/tag/v0.7.6
***

