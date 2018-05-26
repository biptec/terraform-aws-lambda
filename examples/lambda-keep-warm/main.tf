# ---------------------------------------------------------------------------------------------------------------------
# CREATE TWO LAMBDA FUNCTIONS AND USE THE KEEP-WARM MODULE TO TRIGGER THEM ON A SCHEDULED BASIS
# The keep-warm module will ensure the two Lambda functions do not have to go through a "cold start."
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE TWO EXAMPLE LAMBDA FUNCTIONS WE WANT TO KEEP WARM
# ---------------------------------------------------------------------------------------------------------------------

module "lambda_example_1" {
  source = "../../modules/lambda"

  name = "${var.name}-example-1"

  source_path = "${path.module}/src"
  runtime     = "nodejs8.10"
  handler     = "index.handler"

  timeout     = 30
  memory_size = 128
}

module "lambda_example_2" {
  source = "../../modules/lambda"

  name = "${var.name}-example-2"

  source_path = "${path.module}/src"
  runtime     = "nodejs8.10"
  handler     = "index.handler"

  timeout     = 30
  memory_size = 128
}

# ---------------------------------------------------------------------------------------------------------------------
# USE THE KEEP WARM MODULE TO INVOKE OUR EXAMPLE LAMBDA FUNCTIONS ON A SCHEDULED BASIS
# ---------------------------------------------------------------------------------------------------------------------

module "keep_warm" {
  source = "../../modules/keep-warm"

  name = "${var.name}"

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

  schedule_expression = "${var.schedule_expression}"
  concurrency         = "${var.concurrency}"
}