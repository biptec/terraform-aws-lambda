terraform {
  # This module is now only being tested with Terraform 0.15.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 0.15.x code.
  required_version = ">= 0.12.26"
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CONFIGURE AWS TO RUN A LAMBDA FUNCTION ON A RECURRING SCHEDULE
# This template configures AWS to run a Lambda function according to a schedule you specify. This is useful for
# asynchronous tasks and background work, such as a backup job to periodically back up a server.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

resource "aws_cloudwatch_event_rule" "scheduled_lambda_job" {
  count               = var.create_resources ? 1 : 0
  name                = var.namespace == null ? "${var.lambda_function_name}-scheduled" : var.namespace
  description         = "Event that runs the lambda function ${var.lambda_function_name} on a periodic schedule"
  schedule_expression = var.schedule_expression

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "scheduled_lambda_job" {
  count     = var.create_resources ? 1 : 0
  rule      = var.create_resources ? aws_cloudwatch_event_rule.scheduled_lambda_job[0].name : null
  target_id = var.namespace == null ? "${var.lambda_function_name}-scheduled" : var.namespace
  arn       = var.lambda_function_arn
}

resource "aws_lambda_permission" "allow_execution_from_cloudwatch" {
  count         = var.create_resources ? 1 : 0
  statement_id  = var.namespace == null ? "${var.lambda_function_name}-scheduled" : var.namespace
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "events.amazonaws.com"
  source_arn    = var.create_resources ? aws_cloudwatch_event_rule.scheduled_lambda_job[0].arn : null
}
