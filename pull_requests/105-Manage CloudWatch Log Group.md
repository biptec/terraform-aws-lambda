# Manage CloudWatch Log Group

**yorinasub17** commented *Jan 24, 2022*

<!--
  Have any questions? Check out the contributing docs at https://docs.gruntwork.io/guides/contributing/, or
  ask in this Pull Request and a Gruntwork core maintainer will be happy to help :)
  Note: Remember to add '[WIP]' to the beginning of the title if this PR is still a work-in-progress.
-->

## Description

<!-- Write a brief description of the changes introduced by this PR -->
Enable the ability to manage the CloudWatch Log Group in terraform that the lambda function uses to stream logs to. This allows you to customize settings like encryption with KMS key and days of log retention.

## TODOs

- [x] Ensure the branch is named correctly with the issue number. e.g: `feature/new-vpc-endpoints-955` or `bug/missing-count-param-434`.
- [x] Update the docs.
- [x] Keep the changes backwards compatible where possible.
- [x] Run the pre-commit checks successfully.
- [x] Run the relevant tests successfully.

## Related Issues

<!--
  Link to the issue that is fixed by this PR (if there is one)
  e.g. Fixes #1234

  Link to an issue that is partially addressed by this PR (if there are any)
  e.g. Addresses #1234

  Link to related issues (if there are any)
  e.g. Related to #1234
-->
Fixes https://github.com/gruntwork-io/terraform-aws-lambda/issues/98

## Backward compatibility

This is **backward incompatible**. Refer to the migration guide:

---

## Migration guide

Each of the modules that create lambda functions have been updated to manage the CloudWatch Log Group in Terraform. This means that terraform will attempt to create the Log Group when you update to this version, which will conflict with the existing Log Group that was created by Lambda when you first deployed the function.

To avoid this creation, you can set the `should_create_cloudwatch_log_group` input variable to `false`.

Alternatively, you can import the existing CloudWatch Log Group using `terragrunt import` (or `terraform` if you are using Terraform) to the new address. The address to use depends on how you are calling the module. The easiest way to find the address is to run a `terragrunt plan` (or `terraform plan` if using Terraform) and look for the `aws_cloudwatch_log_group.log_aggregation` resource in the plan, and use the full address to the resource being created.
<br />
***


**yorinasub17** commented *Jan 26, 2022*

Thanks for review! Going to merge this in now.
***

