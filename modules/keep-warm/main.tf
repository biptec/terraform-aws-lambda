terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = ">= 0.12.26"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A LAMBDA FUNCTION THAT INVOKES OTHER LAMBDA FUNCTIONS ON A SCHEDULED BASIS TO KEEP THEM "WARM"
# ---------------------------------------------------------------------------------------------------------------------

module "keep_warm" {
  source = "../lambda"

  name        = var.name
  description = "A lambda function that invokes other lambda functions on a scheduled basis to keep them warm"

  source_path = "${path.module}/src"
  runtime     = "nodejs12.x"
  handler     = "index.handler"

  timeout     = 30
  memory_size = 128

  environment_variables = {
    FUNCTION_TO_EVENT_MAP = jsonencode(var.function_to_event_map)
    CONCURRENCY           = var.concurrency
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE THE LAMBDA FUNCTION TO RUN ON A SCHEDULED BASIS
# ---------------------------------------------------------------------------------------------------------------------

module "scheduled" {
  source = "../scheduled-lambda-job"

  lambda_function_name = module.keep_warm.function_name
  lambda_function_arn  = module.keep_warm.function_arn
  schedule_expression  = var.schedule_expression
}

# ---------------------------------------------------------------------------------------------------------------------
# GIVE THE LAMBDA FUNCTION PERMISSION TO INVOKE THE LAMBDA FUNCTIONS IT IS TRYING TO KEEP WARM
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "allow_invoking_other_functions" {
  name   = "allow-invoking-other-functions"
  role   = module.keep_warm.iam_role_id
  policy = data.aws_iam_policy_document.allow_invoking_other_functions.json
}

data "aws_iam_policy_document" "allow_invoking_other_functions" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = keys(var.function_to_event_map)
  }
}
