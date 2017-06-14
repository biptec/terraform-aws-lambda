# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY CODE AS A LAMBDA FUNCTION IN AWS
# This module takes your code and uploads it to AWS so it can run as an AWS Lambda function.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# There are FOUR functions below, although only one will actually be created. This is because we have two optional
# features--whether to run in a VPC or not and whether to find the deployment package in an S3 bucket or the local file
# system--that are controlled via inline blocks, and there is no way to make inline blocks conditional in Terraform.
# Therefore, to handle the 4 possible permutations, we copy/paste the same exact settings, other than these inline
# blocks. Make sure to update all 4 permutations any time you make a change!!
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "function_in_vpc_code_in_s3" {
  count = "${var.run_in_vpc * (1 - signum(length(var.source_dir)))}"

  function_name = "${var.name}"
  description = "${var.description}"
  publish = "${var.enable_versioning}"

  s3_bucket = "${var.s3_bucket}"
  s3_key = "${var.s3_key}"
  s3_object_version = "${var.s3_object_version}"

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

resource "aws_lambda_function" "function_in_vpc_code_in_local_folder" {
  count = "${var.run_in_vpc * signum(length(var.source_dir))}"

  function_name = "${var.name}"
  description = "${var.description}"
  publish = "${var.enable_versioning}"

  filename = "${length(var.source_dir) > 0 ? data.archive_file.source_code.*.output_path : ""}"
  source_code_hash = "${length(var.source_dir) > 0 ? data.archive_file.source_code.*.output_base64sha256 : ""}"

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

resource "aws_lambda_function" "function_not_in_vpc_code_in_s3" {
  count = "${(1 - var.run_in_vpc) * (1 - signum(length(var.source_dir)))}"

  function_name = "${var.name}"
  description = "${var.description}"
  publish = "${var.enable_versioning}"

  s3_bucket = "${var.s3_bucket}"
  s3_key = "${var.s3_key}"
  s3_object_version = "${var.s3_object_version}"

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

resource "aws_lambda_function" "function_not_in_vpc_code_in_local_folder" {
  count = "${(1 - var.run_in_vpc) * signum(length(var.source_dir))}"

  function_name = "${var.name}"
  description = "${var.description}"
  publish = "${var.enable_versioning}"

  filename = "${length(var.source_dir) > 0 ? data.archive_file.source_code.*.output_path : ""}"
  source_code_hash = "${length(var.source_dir) > 0 ? data.archive_file.source_code.*.output_base64sha256 : ""}"

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
  count = "${signum(length(var.source_dir))}"
  type = "zip"
  source_dir = "${var.source_dir}"
  output_path = "${var.source_dir}/lambda.zip"
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
