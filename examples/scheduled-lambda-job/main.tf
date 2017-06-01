# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A LAMBDA FUNCTION AND SCHEDULE IT TO RUN ON A PERIODIC BASIS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

module "lambda_function" {
  source = "../../modules/lambda"

  name = "${var.name}"
  description = "An example of how to process images in S3 with Lambda"

  source_dir = "${path.module}/javascript"
  runtime = "nodejs6.10"
  handler = "index.handler"

  timeout = 30
  memory_size = 128
}

# ---------------------------------------------------------------------------------------------------------------------
# SCHEDULE THE LAMBDA FUNCTION TO RUN ONCE PER MINUTE
# ---------------------------------------------------------------------------------------------------------------------

module "scheduled" {
  source = "../../modules/scheduled-lambda-job"

  lambda_function_name = "${module.lambda_function.function_name}"
  lambda_function_arn = "${module.lambda_function.function_arn}"
  schedule_expression = "rate(1 minute)"
}