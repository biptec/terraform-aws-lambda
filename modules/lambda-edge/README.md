# Lambda@Edge Function Module

This module makes it easy to deploy and manage an [AWS Lambda@Edge](https://aws.amazon.com/lambda/edge/) function.
Lambda@Edge gives you a way to run code on-demand in AWS Edge locations without having to manage servers.

Lambda@Edge has the following limitations compared to regular Lambda (see
[the CloudFront Developer Guide](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-requirements-limits.html)
for the full details):
* The functions must not have any environment variables.
* The execution timeout must not be higher than 30 seconds.
* The function must be versioned in order to be a target for Cloudfront events.
* The function must be deployed in the `us-west-1` region.
* The function runtime must be `nodejs6.10`.





## How do you use this module?

* See the [root README](/README.md) for instructions on using Terraform modules.
* See the [lambda-edge example](/examples/lambda-edge) folder for sample usage.
* See [vars.tf](./vars.tf) for all the variables you can set on this module.

The general idea is to:

1. Create a folder that contains your source code in one of the supported languages: Python, JavaScript, Java, etc (see
   [Lambda programming model](https://docs.aws.amazon.com/lambda/latest/dg/programming-model-v2.html) for the complete
   list).
1. Use this `lambda-edge` module to automatically zip that folder, upload it to AWS, and configure it as a Lambda function.
1. Trigger your Lambda function using one of the following options:
    1. [AWS Console UI](https://console.aws.amazon.com/lambda/home).
    1. [AWS API](http://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html).
    1. [AWS CLI](http://docs.aws.amazon.com/cli/latest/reference/lambda/invoke.html).
    1. [API Gateway](http://docs.aws.amazon.com/apigateway/latest/developerguide/getting-started.html) API you expose.
    1. An [event source](http://docs.aws.amazon.com/lambda/latest/dg/invoking-lambda-function.html), such as a new
       Cloudfront event.




## What is AWS Lambda?

[AWS Lambda](https://aws.amazon.com/lambda/) lets you run code without provisioning or managing servers. You define a
function in a supported language (currently: Python, JavaScript, Java, and C#), upload the code to Lambda, specify how
that function can be triggered, and then AWS Lambda takes care of all the details of deploying and scaling the
infrastructure to run that code.




## How do you add additional IAM policies and permissions?

By default, the `lambda-edge` module configures your lambda function with an IAM role that allows it to write logs to
CloudWatch Logs. The ID of the IAM role is exported as the output `iam_role_id` and the ID of the lambda function is
exported as the output `function_arn`, so you can add custom rules using the `aws_iam_role_policy` or
`aws_lambda_permission` resources, respectively. For example, to allow your lambda function to be triggered by SNS:

```hcl
module "my_lambda_function" {
  source = "git::git@github.com:gruntwork-io/package-lambda.git//modules/lambda-edge?ref=v1.0.8"
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
