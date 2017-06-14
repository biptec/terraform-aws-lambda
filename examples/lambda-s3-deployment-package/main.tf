# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A LAMBDA FUNCTION WITH A DEPLOYMENT PACKAGE IN S3
# This is an example of how to create a lambda function that runs code that is uploaded to S3.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

module "lambda_s3" {
  source = "../../modules/lambda"

  name = "${var.name}"
  description = "An example of how to create a lambda function from a deployment package in S3"

  s3_bucket = "${aws_s3_bucket.source_code.bucket}"
  s3_key = "${aws_s3_bucket_object.deployment_package.key}"

  runtime = "python2.7"
  handler = "index.handler"

  timeout = 30
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
  bucket = "${aws_s3_bucket.source_code.id}"
  key = "lambda.zip"
  source = "${data.archive_file.source_code.output_path}"
}

data "archive_file" "source_code" {
  type = "zip"
  source_dir = "${path.module}/python"
  output_path = "${path.module}/python/lambda.zip"
}
