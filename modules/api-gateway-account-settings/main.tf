# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE THE GLOBAL REGIONAL API GATEWAY SETTINGS
# ---------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = ">= 0.12.26"
}

# ---------------------------------------------------------------------------------------------------------------------
# ADD THE API GATEWAY IAM PERMISSIONS AT THE REGION ACCOUNT LEVEL
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_api_gateway_account" "api_gateway" {
  count               = var.create_resources ? 1 : 0
  cloudwatch_role_arn = aws_iam_role.cloudwatch[0].arn
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE IAM ROLE API GATEWAY CAN ASSUME
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "cloudwatch" {
  count              = var.create_resources ? 1 : 0
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.api_gateway_iam_role.json
}

data "aws_iam_policy_document" "api_gateway_iam_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# ATTACH CLOUDWATCH PERMISSIONS TO THE IAM ROLE
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "cloudwatch" {
  count  = var.create_resources ? 1 : 0
  name   = "cloudwatch"
  role   = aws_iam_role.cloudwatch.*.id[0]
  policy = data.aws_iam_policy_document.cloudwatch_logs.json
}

data "aws_iam_policy_document" "cloudwatch_logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]
    resources = ["*"]
  }
}
