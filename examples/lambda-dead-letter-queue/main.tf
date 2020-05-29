# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A LAMBDA FUNCTION THAT MAKES HTTP REQUESTS
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE DEAD LETTER QUEUE
# Using SQS
# ---------------------------------------------------------------------------------------------------------------------

module "sqs" {
  source = "git::git@github.com:gruntwork-io/package-messaging.git//modules/sqs?ref=v0.3.2"

  name = var.name

}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

module "lambda_dlq" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:gruntwork-io/package-lambda.git//modules/lambda?ref=v1.0.8"
  source = "../../modules/lambda"

  name        = var.name
  description = "An example of sending execution errors to SQS"

  source_path = "${path.module}/python"
  runtime     = "python3.7"
  handler     = "index.handler"

  tags = {
    Name = "lambda-dead-letter-queue"
  }

  # Adds SQS arn to dead-letter-config for the lambda.
  dead_letter_target_arn = module.sqs.queue_arn

  timeout     = 30
  memory_size = 128
}

# ---------------------------------------------------------------------------------------------------------------------
# LAMBDA SQS PERMISSIONS
# ---------------------------------------------------------------------------------------------------------------------

data "aws_iam_policy_document" "sqs_send" {
  statement {
    sid    = "AllowSendMessage"
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
    ]
    resources = [module.sqs.queue_arn]

  }
}

resource "aws_iam_role_policy" "lambda_sqs_send" {
  role   = module.lambda_dlq.iam_role_id
  policy = data.aws_iam_policy_document.sqs_send.json
}

# ---------------------------------------------------------------------------------------------------------------------
# ASYNCHRONOUS CONFIG
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function_event_invoke_config" "async_config" {
  function_name                = module.lambda_dlq.function_name
  maximum_event_age_in_seconds = 60
  maximum_retry_attempts       = 0
}
