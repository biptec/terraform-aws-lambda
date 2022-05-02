# Perpetual changes shown in plan when using image_uri and no other custom settings

**pjroth** commented *Nov 9, 2021*

Using the following terraform code I am able to successfully apply changes:
```
module "schedule_runner_lambda" {
  source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/lambda?ref=v0.14.1"

  memory_size = 1024
  name        = "my-lambda"
  description = "A description"
  timeout     = 60

  image_uri = "1234567890.dkr.ecr.us-east-1.amazonaws.com/my-company/my-service"
  environment_variables = {
    MY_VAR_A  = "some value"
    MY_VAR_B  = "other value"
  }

  run_in_vpc               = true
  vpc_id                      = "my-vpc-id"
  subnet_ids               = "my-subnet-ids"
  should_create_outbound_rule = true
}
```
If I perform another plan, it shows the following changes of:
```
+ image_config {
  + command : [ ]
  + entry_point : [ ]
+ }
```

I would expect to not see changes in the plan like this when there are no changes to the terraform code.

Thank you!

<br />
***


**brikis98** commented *Nov 16, 2021*

Ah, interesting. I'm guessing the issue is here: https://github.com/gruntwork-io/terraform-aws-lambda/blob/master/modules/lambda/main.tf#L103-L110. We should probably only add that `dynamic` block not only if `local.use_docker_image` is `true`, but also if at least one of `var.entry_point`, `var.command`, or `var.working_directory` is set. Would you be up for a quick PR to see if that fixes the diff for you?
***

**gcagle3** commented *Apr 28, 2022*

Hi @pjroth! I'm happy to report that this bug should be fixed in release [v0.18.5](https://github.com/gruntwork-io/terraform-aws-lambda/releases/tag/v0.18.5) of the module. If you get time, please test this and let us know if this resolves your issue or if any additional changes are needed. Thank you!
***

