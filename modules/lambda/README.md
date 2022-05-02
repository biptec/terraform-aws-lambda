# Lambda Function Module

This module makes it easy to deploy and manage an [AWS Lambda](https://aws.amazon.com/lambda/) function. Lambda gives
you a way to run code on-demand in AWS without having to manage servers. 





## How do you use this module?

* See the [root README](https://github.com/biptec/terraform-aws-lambda/blob/v0.4.0/README.md) for instructions on using Terraform modules.
* See the [lambda-s3 example](https://github.com/biptec/terraform-aws-lambda/blob/v0.4.0/examples/lambda-s3) folder for sample usage.
* See [vars.tf](./vars.tf) for all the variables you can set on this module.

The general idea is to:

1. Create a folder that contains your source code in one of the supported languages: Python, JavaScript, Java, etc (see 
   [Lambda programming model](https://docs.aws.amazon.com/lambda/latest/dg/programming-model-v2.html) for the complete 
   list).
1. Use this `lambda` module to automatically zip that folder, upload it to AWS, and configure it as a Lambda function. 
1. Trigger your Lambda function using one of the following options:
    1. [AWS Console UI](https://console.aws.amazon.com/lambda/home).
    1. [AWS API](http://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html). 
    1. [AWS CLI](http://docs.aws.amazon.com/cli/latest/reference/lambda/invoke.html).
    1. [API Gateway](http://docs.aws.amazon.com/apigateway/latest/developerguide/getting-started.html) API you expose.
    1. An [event source](http://docs.aws.amazon.com/lambda/latest/dg/invoking-lambda-function.html), such as a new 
       message on an SNS topic or a new file uploaded to S3.




## What is AWS Lambda?

[AWS Lambda](https://aws.amazon.com/lambda/) lets you run code without provisioning or managing servers. You define a
function in a supported language (currently: Python, JavaScript, Java, and C#), upload the code to Lambda, specify how 
that function can be triggered, and then AWS Lambda takes care of all the details of deploying and scaling the 
infrastructure to run that code.




## How do you add additional IAM policies and permissions?

By default, the `lambda` module configures your lambda function with an IAM role that allows it to write logs to 
CloudWatch Logs. The ID of the IAM role is exported as the output `iam_role_id` and the ID of the lambda function is 
exported as the output `function_arn`, so you can add custom rules using the `aws_iam_role_policy` or 
`aws_lambda_permission` resources, respectively. For example, to allow your lambda function to be triggered by SNS:

```hcl
module "my_lambda_function" {
  source = "git::git@github.com:gruntwork-io/package-lambda.git//modules/lambda?ref=v1.0.8"
  # (params omitted)
}

resource "aws_lambda_permission" "with_sns" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = "${module.my_lambda_function.function_arn}"
  principal = "sns.amazonaws.com"
  source_arn = "${aws_sns_topic.default.arn}"
}
```




## How do you give the lambda function access to a VPC?

By default, your Lambda functions do not have access to your VPCs or subnets. If the lambda function needs to be able 
to talk to something directly within your VPC, you need to:
 
1. Set the `run_in_vpc` parameter to `true`.
1. Specify the ID of the VPC your Lambda function should be able to access via the `vpc_id` parameter.
1. Specify the IDs of the subnets your Lambda function should be able to access via the `subnet_ids` parameter. 
 
 
Here's an example:
 
```hcl
module "my_lambda_function" {
  source = "git::git@github.com:gruntwork-io/package-lambda.git//modules/lambda?ref=v1.0.8"
  
  run_in_vpc = true
  vpc_id = "${data.terraform_remote_state.vpc.id}"
  subnet_ids = "${data.terraform_remote_state.vpc.private_app_subnet_ids}"
  
  # (other params omitted)
}
``` 

When you set `run_in_vpc` to `true`, this module also creates a Security Group for your Lambda function. By default, 
this security group does not allow any inbound or outbound requests, so if the Lambda function needs to make requests 
to the outside world, you will need to add the corresponding rules to that security group (its ID is available as the
output variable `security_group_id`):

```hcl
module "my_lambda_function" {
  source = "git::git@github.com:gruntwork-io/package-lambda.git//modules/lambda?ref=v1.0.8"
  
  run_in_vpc = true
  vpc_id = "${data.terraform_remote_state.vpc.id}"
  subnet_ids = "${data.terraform_remote_state.vpc.private_app_subnet_ids}"
  
  # (other params omitted)
}

resource "aws_security_group_rule" "allow_all_outbound_to_vpc" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["${data.terraform_remote_state.vpc.vpc_cidr_block}"]
  security_group_id = "${module.my_lambda_function.security_group_id}"
}
```

Check out the [lambda-vpc example](https://github.com/biptec/terraform-aws-lambda/blob/v0.4.0/examples/lambda-vpc) for working sample code. Make sure to note the Known Issues
section in that example's README.