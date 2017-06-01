# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A LAMBDA FUNCTION THAT MAKES HTTP REQUESTS
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
  description = "An example of how to process images in S3 with Lambda"

  # Notice how the source_dir is set to python/build, which doesn't initially exist. That's because you need to run
  # the build process for the code before deploying it with Terraform. See README.md for instructions.
  source_dir = "${path.module}/python/build"
  runtime = "python2.7"

  # The Lambda zip file will be extracted into /var/task. Our zip contains two folders: a src folder with our Lambda
  # code, including the handler, and a dependencies folder that has our dependencies. Below, we tell the Lambda
  # function to find its handler in the src folder (https://forums.aws.amazon.com/thread.jspa?messageID=667590) and
  # configure the PYTHONPATH environment variable so it knows where to find dependencies
  # (https://docs.python.org/2/using/cmdline.html#envvar-PYTHONPATH).
  handler = "src/index.handler"
  environment_variables = {
    PYTHONPATH = "/var/task/dependencies"
  }

  timeout = 30
  memory_size = 128
}
