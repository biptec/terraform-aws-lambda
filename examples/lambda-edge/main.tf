# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A LAMBDA FUNCTION TO LOG INCOMING REQUESTS TO A CLOUDFRONT DISTRIBUTION
# Note: this example does NOT yet have the CloudFront triggers integrated! You must enable them manually.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module is now only being tested with Terraform 1.1.x. However, to make upgrading easier, we are setting 1.0.0 as the minimum version.
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 4.0"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

module "lambda_edge" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/lambda-edge?ref=v1.0.8"
  source = "../../modules/lambda-edge"

  name        = var.name
  description = "An example of how to interact with CloudFront with Lambda@Edge"

  source_path = "${path.module}/nodejs"
  runtime     = "nodejs12.x"
  handler     = "index.handler"

  timeout     = 30
  memory_size = 128
  tags = {
    Name = "lambda-edge"
  }
}
