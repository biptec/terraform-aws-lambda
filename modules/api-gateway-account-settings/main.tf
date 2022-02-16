# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE THE GLOBAL REGIONAL API GATEWAY SETTINGS
# ---------------------------------------------------------------------------------------------------------------------


terraform {
  # This module is now only being tested with Terraform 1.1.x. However, to make upgrading easier, we are setting 1.0.0 as the minimum version.
  required_version = ">= 1.0.0"
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
  count  = var.create_resources && local.use_inline_policies ? 1 : 0
  name   = "cloudwatch"
  role   = aws_iam_role.cloudwatch[0].id
  policy = data.aws_iam_policy_document.cloudwatch_logs.json
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count      = var.create_resources && var.use_managed_iam_policies ? 1 : 0
  role       = aws_iam_role.cloudwatch[0].id
  policy_arn = aws_iam_policy.cloudwatch[0].arn
}

resource "aws_iam_policy" "cloudwatch" {
  count       = var.create_resources && var.use_managed_iam_policies ? 1 : 0
  name_prefix = "api-gateway-allow-cloudwatch"
  description = "IAM Policy to allow API Gateway to access CloudWatch for reporting metrics and logs."
  policy      = data.aws_iam_policy_document.cloudwatch_logs.json
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
