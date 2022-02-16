terraform {
  # This module is now only being tested with Terraform 1.1.x. However, to make upgrading easier, we are setting 1.0.0 as the minimum version.
  required_version = ">= 1.0.0"
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

  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_log_group_kms_key_id
  cloudwatch_log_group_tags              = var.cloudwatch_log_group_tags

  # Feed forward backward compatibility feature flags
  should_create_cloudwatch_log_group = var.should_create_cloudwatch_log_group
  use_managed_iam_policies           = var.use_managed_iam_policies
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
  count  = local.use_inline_policies ? 1 : 0
  name   = "allow-invoking-other-functions"
  role   = module.keep_warm.iam_role_id
  policy = data.aws_iam_policy_document.allow_invoking_other_functions.json
}

resource "aws_iam_role_policy_attachment" "allow_invoking_other_functions" {
  count      = var.use_managed_iam_policies ? 1 : 0
  role       = module.keep_warm.iam_role_id
  policy_arn = aws_iam_policy.allow_invoking_other_functions[0].arn
}

resource "aws_iam_policy" "allow_invoking_other_functions" {
  count       = var.use_managed_iam_policies ? 1 : 0
  name_prefix = "${var.name}-allow-invoke"
  description = "IAM Policy to allow invoking Lambda functions on a periodic schedule."
  policy      = data.aws_iam_policy_document.allow_invoking_other_functions.json
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
