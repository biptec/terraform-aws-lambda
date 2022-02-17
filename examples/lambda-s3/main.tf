# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A LAMBDA FUNCTION TO PROCESS IMAGES IN S3
# This function can download an image and return its base64-encoded contents.
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
  description = "An example of how to process images in S3 with Lambda"

  source_path = "${path.module}/python"
  runtime     = "python3.9"
  handler     = "index.handler"

  timeout     = 30
  memory_size = 128

  reserved_concurrent_executions = var.reserved_concurrent_executions
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN S3 BUCKET AND UPLOAD AN IMAGE
# This is used for testing/demonstration
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "images" {
  bucket = "${lower(var.name)}-images-test"
}

resource "aws_s3_bucket_object" "gruntwork_logo" {
  bucket = aws_s3_bucket.images.id
  key    = "gruntwork-logo.png"
  source = "${path.module}/images/gruntwork-logo.png"
}

# ---------------------------------------------------------------------------------------------------------------------
# GIVE THE LAMBDA FUNCTION PERMISSIONS TO ACCESS THE S3 BUCKET
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "access_s3_bucket" {
  role   = module.lambda_s3.iam_role_id
  policy = data.aws_iam_policy_document.access_s3_bucket.json
}

data "aws_iam_policy_document" "access_s3_bucket" {
  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.images.arn}/*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.images.arn]
  }
}
