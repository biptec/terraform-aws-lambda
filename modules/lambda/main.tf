# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY CODE AS A LAMBDA FUNCTION IN AWS
# This module takes your code and uploads it to AWS so it can run as an AWS Lambda function.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# There are two functions below, one in a VPC and one not, and which one gets created depends on var.run_in_vpc.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "function_in_vpc" {
  count = "${var.run_in_vpc}"

  function_name = "${var.name}"
  description = "${var.description}"
  publish = "${var.enable_versioning}"

  filename = "${data.archive_file.source_code.output_path}"
  source_code_hash = "${data.archive_file.source_code.output_base64sha256}"

  runtime = "${var.runtime}"
  handler = "${var.handler}"
  timeout = "${var.timeout}"
  memory_size = "${var.memory_size}"
  kms_key_arn = "${var.kms_key_arn}"

  role = "${aws_iam_role.lambda.arn}"
  # We need this policy to be created before we try to create the lambda job, or you get an error about not having
  # the CreateNetworkInterface permission, which the lambda job needs to work within a VPC
  depends_on = ["aws_iam_role_policy.network_interfaces_for_lamda"]

  vpc_config {
    subnet_ids = ["${var.subnet_ids}"]
    security_group_ids = ["${aws_security_group.lambda.*.id}"]
  }

  environment {
    variables = "${var.environment_variables}"
  }

  # Due to a bug in Terraform, this is currently disabled: https://github.com/hashicorp/terraform/issues/14961
  #
  # dead_letter_config {
  #   target_arn = "${var.dead_letter_target_arn}"
  # }
}

resource "aws_lambda_function" "function_not_in_vpc" {
  count = "${1 - var.run_in_vpc}"

  function_name = "${var.name}"
  description = "${var.description}"
  publish = "${var.enable_versioning}"

  filename = "${data.archive_file.source_code.output_path}"
  source_code_hash = "${data.archive_file.source_code.output_base64sha256}"

  runtime = "${var.runtime}"
  handler = "${var.handler}"
  timeout = "${var.timeout}"
  memory_size = "${var.memory_size}"
  kms_key_arn = "${var.kms_key_arn}"

  role = "${aws_iam_role.lambda.arn}"

  environment {
    variables = "${var.environment_variables}"
  }

  # Due to a bug in Terraform, this is currently disabled: https://github.com/hashicorp/terraform/issues/14961
  #
  # dead_letter_config {
  #   target_arn = "${var.dead_letter_target_arn}"
  # }
}

# ---------------------------------------------------------------------------------------------------------------------
# ZIP UP THE LAMBDA FUNCTION SOURCE CODE
# ---------------------------------------------------------------------------------------------------------------------

data "archive_file" "source_code" {
  type = "zip"
  source_dir = "${var.source_dir}"
  output_path = "${var.zip_dir == "" ? "${var.source_dir}/lambda.zip" : var.zip_dir}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP FOR THE LAMBDA JOB
# If this lambda function has access to a VPC (var.run_in_vpc is true), we add a security group that controls what
# network traffic can go in and out of the lambda function. We export the id of the security group so users can add
# custom rules.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "lambda" {
  count = "${var.run_in_vpc}"

  name = "${var.name}-lambda"
  description = "Security group for the lambda function ${var.name}"
  vpc_id = "${var.vpc_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN IAM ROLE FOR THE LAMBDA FUNCTION
# This controls what resources the lambda function can access and who can trigger the lambda job. We export the id of
# the IAM role so users can add custom permissions.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "lambda" {
  name = "${var.name}"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_role.json}"
}

data "aws_iam_policy_document" "lambda_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GIVE THE LAMBDA FUNCTION PERMISSIONS TO LOG TO CLOUDWATCH
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "logging_for_lambda" {
  name = "${var.name}-logging"
  role = "${aws_iam_role.lambda.id}"
  policy = "${data.aws_iam_policy_document.logging_for_lambda.json}"
}

data "aws_iam_policy_document" "logging_for_lambda" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GIVE THE LAMBDA FUNCTION PERMISSIONS TO CREATE NETWORK INTERFACES SO IT CAN RUN IN A VPC
# These resources are only created if var.run_in_vpc is true.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "network_interfaces_for_lamda" {
  count = "${var.run_in_vpc}"

  name = "${var.name}-network-interfaces"
  role = "${aws_iam_role.lambda.id}"
  policy = "${element(data.aws_iam_policy_document.network_interfaces_for_lamda.*.json, count.index)}"
}

data "aws_iam_policy_document" "network_interfaces_for_lamda" {
  count = "${var.run_in_vpc}"

  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DetachNetworkInterface",
      "ec2:ModifyNetworkInterfaceAttribute",
      "ec2:ResetNetworkInterfaceAttribute"
    ]
    resources = ["*"]
  }
}
