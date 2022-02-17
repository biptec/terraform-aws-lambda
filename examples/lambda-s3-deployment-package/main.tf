# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A LAMBDA FUNCTION WITH A DEPLOYMENT PACKAGE IN S3
# This is an example of how to create a lambda function that runs code that is uploaded to S3.
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

module "lambda_s3" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/lambda?ref=v1.0.8"
  source = "../../modules/lambda"

  name        = var.name
  description = "An example of how to create a lambda function from a deployment package in S3"

  s3_bucket = aws_s3_bucket.source_code.bucket
  s3_key    = aws_s3_bucket_object.deployment_package.key

  runtime = "python3.9"
  handler = "index.handler"

  timeout     = 30
  memory_size = 128
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN S3 BUCKET AND UPLOAD OUR ZIPPED-UP CODE TO IT
# Normally, you would have some sort of build process create your deployment package and upload it to S3, but to keep
# this example simple, we are doing it directly in the Terraform code.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "source_code" {
  bucket = "${lower(var.name)}-s3-deployment-package-test"
}

resource "aws_s3_bucket_object" "deployment_package" {
  bucket = aws_s3_bucket.source_code.id
  key    = "lambda.zip"
  source = data.archive_file.source_code.output_path
}

data "archive_file" "source_code" {
  type        = "zip"
  source_dir  = "${path.module}/python"
  output_path = "${path.module}/python/lambda.zip"
}
