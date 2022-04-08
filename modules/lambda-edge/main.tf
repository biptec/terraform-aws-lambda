# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY CODE AS A LAMBDA FUNCTION IN AWS
# This module takes your code and uploads it to AWS so it can run as an AWS Lambda function.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module is now only being tested with Terraform 1.1.x. However, to make upgrading easier, we are setting 1.0.0 as the minimum version.
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0, < 4.0"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "function" {

  depends_on = [
    # Make sure the CloudWatch Log Group is created before creating the function so that Lambda doesn't create a new
    # one.
    aws_cloudwatch_log_group.log_aggregation,
  ]

  function_name = var.name
  description   = var.description
  publish       = var.enable_versioning

  # When source_path is set, it indicates that the function should come from the local file path.
  filename         = var.source_path != null ? local.zip_file_path : null
  source_code_hash = var.source_path != null && var.set_source_code_hash ? local.source_code_hash : null

  # When source_path is not set (null), it indicates that the function should come from S3.
  s3_bucket         = var.source_path == null ? var.s3_bucket : null
  s3_key            = var.source_path == null ? var.s3_key : null
  s3_object_version = var.source_path == null ? var.s3_object_version : null

  runtime     = var.runtime
  handler     = var.handler
  timeout     = var.timeout
  memory_size = var.memory_size
  kms_key_arn = var.kms_key_arn

  reserved_concurrent_executions = var.reserved_concurrent_executions

  role = aws_iam_role.lambda.arn

  tags = var.tags

  # Terraform will error if target_arn for dead_letter_config is just nil.
  # Workaround is to dynamically generic this block if the string length for dead_letter_target_arn is not 0.
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn == null ? [] : [1]
    content {
      target_arn = var.dead_letter_target_arn
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ZIP UP THE LAMBDA FUNCTION SOURCE CODE
# Note that if var.skip_zip is true, then we assume that var.source_path is the path to an already-zipped file.
# ---------------------------------------------------------------------------------------------------------------------

data "archive_file" "source_code" {
  count       = (!var.skip_zip) && var.source_path != null ? 1 : 0
  type        = "zip"
  source_dir  = var.source_path
  output_path = var.zip_output_path == null ? "${path.module}/${var.name}_lambda.zip" : var.zip_output_path
}

locals {
  source_code_hash = (
    var.skip_zip
    ? filebase64sha256(var.source_path)
    : join(",", data.archive_file.source_code.*.output_base64sha256)
  )

  zip_file_path = var.skip_zip ? var.source_path : join("", data.archive_file.source_code.*.output_path)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONALLY CREATE A CLOUDWATCH LOG GROUP FOR THE LAMBDA JOB
# AWS documentation states that CloudWatch log group names for lambda@edge funtions are prepended with `us-east-1.`.
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-cloudwatch-metrics-logging.html
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "log_aggregation" {
  count             = var.should_create_cloudwatch_log_group ? 1 : 0
  name              = "/aws/lambda/us-east-1.${var.name}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id
  tags              = var.cloudwatch_log_group_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONALLY CREATE A CLOUDWATCH LOG SUBSCRIPTION FILTER FOR THE LAMBDA JOB
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_cloudwatch_log_subscription_filter" "log_aggregation" {
  count = var.should_create_cloudwatch_log_group && var.cloudwatch_log_group_subscription_destination_arn != null ? 1 : 0

  name            = "${aws_cloudwatch_log_group.log_aggregation[0].id}-subscription"
  log_group_name  = aws_cloudwatch_log_group.log_aggregation[0].id
  filter_pattern  = var.cloudwatch_log_group_subscription_filter_pattern
  destination_arn = var.cloudwatch_log_group_subscription_destination_arn
  role_arn        = var.cloudwatch_log_group_subscription_role_arn
  distribution    = var.cloudwatch_log_group_subscription_distribution
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN IAM ROLE FOR THE LAMBDA FUNCTION
# This controls what resources the lambda function can access and who can trigger the lambda job. We export the id of
# the IAM role so users can add custom permissions.
#
# TODO: It looks like you need some IAM permissions to be able to trigger this function from CloudFront. Not clear
# if those permissions go here or in the CloudFront trigger:
# https://docs.aws.amazon.com/lambda/latest/dg/lambda-edge.html#lambda-edge-permissions
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "lambda" {
  name                 = var.name
  assume_role_policy   = data.aws_iam_policy_document.lambda_role.json
  permissions_boundary = var.lambda_role_permissions_boundary_arn

  tags = var.tags
}

data "aws_iam_policy_document" "lambda_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "lambda.amazonaws.com",
        "edgelambda.amazonaws.com",
      ]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GIVE THE LAMBDA FUNCTION PERMISSIONS TO LOG TO CLOUDWATCH
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "logging_for_lambda" {
  count  = local.use_inline_policies ? 1 : 0
  name   = "${var.name}-logging"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.logging_for_lambda.json
}

resource "aws_iam_role_policy_attachment" "logging_for_lambda" {
  count      = var.use_managed_iam_policies ? 1 : 0
  role       = aws_iam_role.lambda.id
  policy_arn = aws_iam_policy.logging_for_lambda[0].arn
}

resource "aws_iam_policy" "logging_for_lambda" {
  count       = var.use_managed_iam_policies ? 1 : 0
  name_prefix = "${var.name}-logging"
  description = "IAM Policy to allow Lambda functions to log to CloudWatch Logs."
  policy      = data.aws_iam_policy_document.logging_for_lambda.json
}

data "aws_iam_policy_document" "logging_for_lambda" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:${data.aws_partition.current.partition}:logs:*:*:*"]
  }
}

# Use this data source to lookup information about the current AWS partition in which Terraform is working.
# This will return the identifier of the current partition (e.g., aws in AWS Commercial, aws-us-gov in AWS GovCloud,
# aws-cn in AWS China).
# https://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html
data "aws_partition" "current" {}
