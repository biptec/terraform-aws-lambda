# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY AN AWS LAMBDA FUNCTION WITH API GATEWAY IN FRONT OF IT
# These templates deploy an AWS Lambda function with API gateway
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module is now only being tested with Terraform 1.0.x. We require at least version 0.15.1 or above
  # because this module uses configuration_aliases, which were only added in Terraform 0.15.0, and we want the latest GPG keys, which were added in 0.15.1.
  required_version = ">= 0.15.1"
}


# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE A LAMBDA SERVICE
# ---------------------------------------------------------------------------------------------------------------------

module "lambda" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/lambda?ref=v1.0.8"
  source = "../../../modules/lambda"

  name        = var.name
  runtime     = "nodejs12.x"
  source_path = "${path.module}/../app"
  handler     = "lambda.handler"
  memory_size = 512
  timeout     = 300

  run_in_vpc = true
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnet_ids.default.ids
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

    # NOTE: We are deploying API Gateway in REGIONAL mode (no CloudFront), so the us-east-1 provider is not necessary.
    # However, the module still requires a reference to us_east_1 alias to function, so we bind it to the default aws
    # provider.
    aws.us_east_1 = aws
  }

  api_name = var.name
  lambda_functions = {
    # Empty string key means proxy everything
    "" = module.lambda.function_name
  }

  # Domain settings
  domain_name             = var.domain_name
  hosted_zone_id          = var.hosted_zone_id
  hosted_zone_tags        = var.hosted_zone_tags
  hosted_zone_domain_name = var.hosted_zone_domain_name
  certificate_domain      = var.certificate_domain
  # Disable the default execute API endpoint if we are binding a domain name.
  enable_execute_api_endpoint = var.domain_name == null

  # Configure regional endpoints
  api_endpoint_configuration = {
    type             = "REGIONAL"
    vpc_endpoint_ids = null # This attribute is only used for private endpoints
  }
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
