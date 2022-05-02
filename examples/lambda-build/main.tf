# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A LAMBDA FUNCTION THAT MAKES HTTP REQUESTS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = ">= 0.12.26"
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
  # source = "git::git@github.com:biptec/terraform-aws-lambda.git//modules/lambda?ref=v1.0.8"
  source           = "../../modules/lambda"
  create_resources = var.create_resources

  name        = var.name
  description = "An example of how to process images in S3 with Lambda"

  # Notice how the source_path is set to python/build, which doesn't initially exist. That's because you need to run
  # the build process for the code before deploying it with Terraform. See README.md for instructions.
  source_path = "${path.module}/python/build"
  runtime     = "python2.7"

  # The Lambda zip file will be extracted into /var/task. Our zip contains two folders: a src folder with our Lambda
  # code, including the handler, and a dependencies folder that has our dependencies. Below, we tell the Lambda
  # function to find its handler in the src folder (https://forums.aws.amazon.com/thread.jspa?messageID=667590) and
  # configure the PYTHONPATH environment variable so it knows where to find dependencies
  # (https://docs.python.org/2/using/cmdline.html#envvar-PYTHONPATH).
  handler = "src/index.handler"
  tags = {
    Name = "lambda-s3"
  }
  environment_variables = {
    PYTHONPATH = "/var/task/dependencies"
  }

  timeout     = 30
  memory_size = 128
}
