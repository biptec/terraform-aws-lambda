# Add docker support for lambda module

**ryfeus** commented *Apr 5, 2021*

Based on the ticket: https://github.com/gruntwork-io/terraform-aws-lambda/issues/64

Adds docker image support for lambda module. Based on [updates](https://registry.terraform.io/providers/hashicorp/aws/3.26.0/docs/resources/lambda_function) to `aws_lambda_function` terraform module. One thing to keep in mind. Change "Zip" -> "Image" and vice versa will result in lambda replacement, not update.

New variables:
- package_type - The Lambda deployment package type. Valid values are Zip and Image. Defaults to Zip.
- image_uri - The ECR image URI containing the function's deployment package.
- entry_point - The ENTRYPOINT for the docker image.
- command - The CMD for the docker image.
- working_directory - The working directory for the docker image.

Changes:
- runtime, handler, layers variables became optional and should be empty when package type is "Zip"
<br />
***


**ryfeus** commented *Apr 6, 2021*

@brikis98 thank you for the feedback. I've updated the PR. 
***

**ryfeus** commented *Apr 7, 2021*

@brikis98 thank you for the feedback and catch. I've updated the PR.
***

**brikis98** commented *Apr 8, 2021*

Looks like the `terraform fmt` pre-commit check failed. Could you run `terraform fmt` on your code changes?
***

**ryfeus** commented *Apr 8, 2021*

@brikis98 thanks for the feedback. I've updated the PR.
***

**brikis98** commented *Apr 9, 2021*

Still getting `terraform fmt` pre-commit errors. If you [bump the pre-commit repo version](https://github.com/gruntwork-io/terraform-aws-lambda/blob/master/.pre-commit-config.yaml#L3) to `0.1.12`, it'll show exactly which files have problems!
***

**ryfeus** commented *Apr 9, 2021*

@brikis98 thank you for the insight. I've updated the config. Just wanted to check - do you use formatting for terraform 12?`terraform fmt` doesn't change any files currently. Thanks.
***

**ryfeus** commented *Apr 13, 2021*

@brikis98 just wanted to check if it's possible to run tests again. Thanks!
***

**brikis98** commented *Apr 14, 2021*

> @brikis98 thank you for the insight. I've updated the config. Just wanted to check - do you use formatting for terraform 12?`terraform fmt` doesn't change any files currently. Thanks.

This repo is currently being tested with Terraform 0.14: https://github.com/gruntwork-io/terraform-aws-lambda/blob/master/.circleci/config.yml#L10. And there were some `fmt` changes between that an older versions. So could you try running `fmt` with 0.14?
***

**ryfeus** commented *Apr 15, 2021*

@brikis98 Thank you for the suggestion. I've run formatting with terraform 14 and updated the PR. May I ask to run the tests one more time?
***

**brikis98** commented *Apr 15, 2021*

Kicking off tests again!
***

**brikis98** commented *Apr 15, 2021*

Got some test failures, but I think they are unrelated to this PR. I believe the cause is a bug in Terraform. I'm trying out a workaround in https://github.com/gruntwork-io/terraform-aws-lambda/pull/66.
***

**brikis98** commented *Apr 15, 2021*

OK, https://github.com/gruntwork-io/terraform-aws-lambda/pull/66 is merged. Could you pull in the latest from `master`?
***

**ryfeus** commented *Apr 15, 2021*

@brikis98 thanks! I've updated the PR with latest updates from `master`.
***

**brikis98** commented *Apr 16, 2021*

Thanks, just kicked off tests again!
***

**brikis98** commented *Apr 16, 2021*

https://github.com/gruntwork-io/terraform-aws-lambda/releases/tag/v0.10.1
***

