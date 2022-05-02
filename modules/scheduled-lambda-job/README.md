# Scheduled Lambda Job Module

This module makes it easy to run an [AWS Lambda](https://aws.amazon.com/lambda/) function (such as one created with the
[lambda module](https://github.com/biptec/terraform-aws-lambda/blob/v0.7.4/modules/lambda)) on a scheduled basis. This is useful for periodic background jobs, such as taking a
daily snapshot of your servers.





## How do you use this module?

* See the [root README](https://github.com/biptec/terraform-aws-lambda/blob/v0.7.4/README.md) for instructions on using Terraform modules.
* See the [scheduled-lambda-job example](https://github.com/biptec/terraform-aws-lambda/blob/v0.7.4/examples/scheduled-lambda-job) folder for sample usage.
* See [vars.tf](./vars.tf) for all the variables you can set on this module.

The general idea is to:

1. Create a Lambda function using the [lambda module](https://github.com/biptec/terraform-aws-lambda/blob/v0.7.4/modules/lambda).
1. Use this `scheduled-lambda-job` module to configure AWS to run that Lambda function according to a schedule you
   specify.





## Background info

For more information on AWS Lambda, how it works, and how to configure your functions, check out the [lambda module
documentation](https://github.com/biptec/terraform-aws-lambda/blob/v0.7.4/modules/lambda).
