# ---------------------------------------------------------------------------------------------------------------------
# CREATE TWO LAMBDA FUNCTIONS AND USE THE KEEP-WARM MODULE TO TRIGGER THEM ON A SCHEDULED BASIS
# The keep-warm module will ensure the two Lambda functions do not have to go through a "cold start."
# ---------------------------------------------------------------------------------------------------------------------

terraform {
  # This module is now only being tested with Terraform 0.15.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 0.15.x code.
  required_version = ">= 0.12.26"
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE TWO EXAMPLE LAMBDA FUNCTIONS WE WANT TO KEEP WARM
# ---------------------------------------------------------------------------------------------------------------------

module "lambda_example_1" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/lambda?ref=v1.0.8"
  source = "../../modules/lambda"

  name = "${var.name}-example-1"

  source_path = "${path.module}/src"
  runtime     = "nodejs12.x"
  handler     = "index.handler"

  timeout     = 30
  memory_size = 128

  environment_variables = {
    DYNAMODB_TABLE_NAME = aws_dynamodb_table.example.name
  }
}

module "lambda_example_2" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/lambda?ref=v1.0.8"
  source = "../../modules/lambda"

  name = "${var.name}-example-2"

  source_path = "${path.module}/src"
  runtime     = "nodejs12.x"
  handler     = "index.handler"

  timeout     = 30
  memory_size = 128

  environment_variables = {
    DYNAMODB_TABLE_NAME = aws_dynamodb_table.example.name
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# USE THE KEEP WARM MODULE TO INVOKE OUR EXAMPLE LAMBDA FUNCTIONS ON A SCHEDULED BASIS
# ---------------------------------------------------------------------------------------------------------------------

module "keep_warm" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/keep-warm?ref=v1.0.8"
  source = "../../modules/keep-warm"

  name = var.name

  # This is a map where the keys are the ARNs of Lambda functions to invoke and the values are the event objects to
  # pass to those functions
  function_to_event_map = {
    "${module.lambda_example_1.function_arn}" = {
      foo = "bar"
    }
    "${module.lambda_example_2.function_arn}" = {
      example = {
        a = 1
        b = 1
        c = 1
      }
    }
  }

  schedule_expression = var.schedule_expression
  concurrency         = var.concurrency
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A DYNAMODB TABLE FOR THE EXAMPLE FUNCTIONS
# Purely for testing purposes, the example Lambda functions write to DynamoDB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_dynamodb_table" "example" {
  name           = var.name
  read_capacity  = 1
  write_capacity = var.concurrency
  hash_key       = "RequestId"
  range_key      = "FunctionId"

  attribute {
    name = "RequestId"
    type = "S"
  }

  attribute {
    name = "FunctionId"
    type = "S"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GIVE THE LAMBDA FUNCTIONS ACCESS TO THE DYNAMODB TABLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "access_dynamodb_1" {
  role   = module.lambda_example_1.iam_role_id
  policy = data.aws_iam_policy_document.access_dynamodb.json
}

resource "aws_iam_role_policy" "access_dynamodb_2" {
  role   = module.lambda_example_2.iam_role_id
  policy = data.aws_iam_policy_document.access_dynamodb.json
}

data "aws_iam_policy_document" "access_dynamodb" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:*"]
    resources = [aws_dynamodb_table.example.arn]
  }
}
