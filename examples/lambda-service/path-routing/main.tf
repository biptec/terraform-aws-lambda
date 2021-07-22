# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY AN AWS LAMBDA FUNCTION WITH API GATEWAY IN FRONT OF IT
# These templates deploy an AWS Lambda function with API gateway
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module is now only being tested with Terraform 0.15.x. We require at least version 0.15.1 or above
  # because this module uses configuration_aliases, which were only added in Terraform 0.15.0, and we want the latest GPG keys, which were added in 0.15.1.
  required_version = ">= 0.15.1"
}


# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE THREE LAMBDA SERVICES WITH DIFFERING MESSAGES TO DEMONSTRATE PATH BASED ROUTING
# ---------------------------------------------------------------------------------------------------------------------

module "hello_world_lambda" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/lambda?ref=v1.0.8"
  source = "../../../modules/lambda"

  name        = "${var.name}-hello-world"
  runtime     = "nodejs12.x"
  source_path = "${path.module}/../app"
  handler     = "lambda.handler"
  memory_size = 512
  timeout     = 300

  run_in_vpc = true
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnet_ids.default.ids

  environment_variables = {
    SERVER_MESSAGE = "hello world"
  }
}

module "hello_lambda" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/lambda?ref=v1.0.8"
  source = "../../../modules/lambda"

  name        = "${var.name}-hello"
  runtime     = "nodejs12.x"
  source_path = "${path.module}/../app"
  handler     = "lambda.handler"
  memory_size = 512
  timeout     = 300

  run_in_vpc = true
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnet_ids.default.ids

  environment_variables = {
    SERVER_MESSAGE = "hello"
  }
}

module "world_lambda" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/lambda?ref=v1.0.8"
  source = "../../../modules/lambda"

  name        = "${var.name}-world"
  runtime     = "nodejs12.x"
  source_path = "${path.module}/../app"
  handler     = "lambda.handler"
  memory_size = 512
  timeout     = 300

  run_in_vpc = true
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnet_ids.default.ids

  environment_variables = {
    SERVER_MESSAGE = "world"
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# USE API GATEWAY TO EXPOSE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

module "api_gateway" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/api-gateway-proxy?ref=v1.0.8"
  source = "../../../modules/api-gateway-proxy"
  providers = {
    aws = aws

    # NOTE: this is only necessary if you are configuring an EDGE domain. For other cases, this can be configured to the
    # base `aws` provider.
    aws.us_east_1 = aws.us_east_1
  }

  api_name = var.name
  lambda_functions = {
    # Sets up the following path based routing:
    # - hello/* => hello_lambda function (only returns "hello")
    # - world/* => world_lambda function (only returns "world")
    "hello" = module.hello_lambda.function_name
    "world" = module.world_lambda.function_name
  }
  enable_root_lambda_function = true
  root_lambda_function_name   = module.hello_world_lambda.function_name
}


# ------------------------------------------------------------------------------
# LOOK UP DEFAULT VPC
# ------------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}
