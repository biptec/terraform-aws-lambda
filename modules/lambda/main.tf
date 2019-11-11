# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY CODE AS A LAMBDA FUNCTION IN AWS
# This module takes your code and uploads it to AWS so it can run as an AWS Lambda function.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ----------------------------------------------------------------------------------------------------------------------
# REQUIRE A SPECIFIC TERRAFORM VERSION OR HIGHER
# This module has been updated with 0.12 syntax, which means it is no longer compatible with any versions below 0.12.
# ----------------------------------------------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.12"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "function" {
  # We need this policy to be created before we try to create the lambda job, or you get an error about not having
  # the CreateNetworkInterface permission, which the lambda job needs to work within a VPC
  depends_on = [aws_iam_role_policy.network_interfaces_for_lamda]

  function_name = var.name
  description   = var.description
  publish       = var.enable_versioning

  # When source_path is set, it indicates that the function should come from the local file path.
  filename         = var.source_path != null ? local.zip_file_path : null
  source_code_hash = var.source_path != null ? local.source_code_hash : null

  # When source_path is not set (null), it indicates that the function should come from S3.
  s3_bucket         = var.source_path == null ? var.s3_bucket : null
  s3_key            = var.source_path == null ? var.s3_key : null
  s3_object_version = var.source_path == null ? var.s3_object_version : null

  runtime     = var.runtime
  handler     = var.handler
  layers      = var.layers
  timeout     = var.timeout
  memory_size = var.memory_size
  kms_key_arn = var.kms_key_arn

  role = aws_iam_role.lambda.arn

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    # The content of the list does not matter, because we are using this as an on off switch based on the input
    # variable.
    for_each = var.run_in_vpc ? ["use_vpc_config"] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = aws_security_group.lambda.*.id
    }
  }

  # Due to a bug in Terraform, this is currently disabled: https://github.com/hashicorp/terraform/issues/14961
  #
  # dead_letter_config {
  #   target_arn = "${var.dead_letter_target_arn}"
  # }
}

# ---------------------------------------------------------------------------------------------------------------------
# ZIP UP THE LAMBDA FUNCTION SOURCE CODE
# Note that if var.skip_zip is true, then we assume that var.source_path is the path to an already-zipped file.
# ---------------------------------------------------------------------------------------------------------------------

data "archive_file" "source_code" {
  count       = (! var.skip_zip) && var.source_path != null ? 1 : 0
  type        = "zip"
  source_dir  = var.source_path
  output_path = var.zip_output_path == null ? "${path.module}/${var.name}_lambda.zip" : var.zip_output_path
}

data "template_file" "hash_from_source_code_zip" {
  count    = var.skip_zip ? 1 : 0
  template = filebase64sha256(var.source_path)
}

locals {
  source_code_hash = (
    var.skip_zip
    ? join(",", data.template_file.hash_from_source_code_zip.*.rendered)
    : join(",", data.archive_file.source_code.*.output_base64sha256)
  )

  zip_file_path = var.skip_zip ? var.source_path : join("", data.archive_file.source_code.*.output_path)
}


# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP FOR THE LAMBDA JOB
# If this lambda function has access to a VPC (var.run_in_vpc is true), we add a security group that controls what
# network traffic can go in and out of the lambda function. We export the id of the security group so users can add
# custom rules.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "lambda" {
  count = var.run_in_vpc ? 1 : 0

  name        = "${var.name}-lambda"
  description = "Security group for the lambda function ${var.name}"
  vpc_id      = var.vpc_id
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN IAM ROLE FOR THE LAMBDA FUNCTION
# This controls what resources the lambda function can access and who can trigger the lambda job. We export the id of
# the IAM role so users can add custom permissions.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "lambda" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.lambda_role.json
}

data "aws_iam_policy_document" "lambda_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GIVE THE LAMBDA FUNCTION PERMISSIONS TO LOG TO CLOUDWATCH
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "logging_for_lambda" {
  name   = "${var.name}-logging"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.logging_for_lambda.json
}

data "aws_iam_policy_document" "logging_for_lambda" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GIVE THE LAMBDA FUNCTION PERMISSIONS TO CREATE NETWORK INTERFACES SO IT CAN RUN IN A VPC
# These resources are only created if var.run_in_vpc is true.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "network_interfaces_for_lamda" {
  count = var.run_in_vpc ? 1 : 0

  name   = "${var.name}-network-interfaces"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.network_interfaces_for_lamda.json
}

data "aws_iam_policy_document" "network_interfaces_for_lamda" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DetachNetworkInterface",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:ResetNetworkInterfaceAttribute",
    ]

    resources = ["*"]
  }
}
