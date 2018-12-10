# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY CODE AS A LAMBDA FUNCTION IN AWS
# This module takes your code and uploads it to AWS so it can run as an AWS Lambda function.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# There are TWO functions below, although only one will actually be created. This is because we have an optional
# feature--whether to find the deployment package in an S3 bucket or the local file
# system--that are controlled via inline blocks, and there is no way to make inline blocks conditional in Terraform.
# Therefore, to handle the 2 possible permutations, we copy/paste the same exact settings, other than these inline
# blocks. Make sure to update all 2 permutations any time you make a change!!
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "function_not_in_vpc_code_in_s3" {
  count = "${(1 - signum(length(var.source_path)))}"

  function_name = "${var.name}"
  description   = "${var.description}"
  publish       = "${var.enable_versioning}"

  s3_bucket         = "${var.s3_bucket}"
  s3_key            = "${var.s3_key}"
  s3_object_version = "${var.s3_object_version}"

  runtime     = "${var.runtime}"
  handler     = "${var.handler}"
  timeout     = "${var.timeout}"
  memory_size = "${var.memory_size}"
  kms_key_arn = "${var.kms_key_arn}"

  role = "${aws_iam_role.lambda.arn}"

  # Due to a bug in Terraform, this is currently disabled: https://github.com/hashicorp/terraform/issues/14961
  #
  # dead_letter_config {
  #   target_arn = "${var.dead_letter_target_arn}"
  # }
}

resource "aws_lambda_function" "function_not_in_vpc_code_in_local_folder" {
  count = "${signum(length(var.source_path))}"

  function_name = "${var.name}"
  description   = "${var.description}"
  publish       = "${var.enable_versioning}"

  filename         = "${data.template_file.zip_file_path.rendered}"
  source_code_hash = "${data.template_file.source_code_hash.rendered}"

  runtime     = "${var.runtime}"
  handler     = "${var.handler}"
  timeout     = "${var.timeout}"
  memory_size = "${var.memory_size}"
  kms_key_arn = "${var.kms_key_arn}"

  role = "${aws_iam_role.lambda.arn}"

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
  count       = "${var.skip_zip ? 0 : signum(length(var.source_path))}"
  type        = "zip"
  source_dir  = "${var.source_path}"
  output_path = "${var.zip_output_path == "" ? "${path.module}/${var.name}_lambda.zip" : "${var.zip_output_path}"}"
}

data "template_file" "hash_from_source_code_zip" {
  count    = "${var.skip_zip}"
  template = "${base64sha256(file(var.source_path))}"
}

data "template_file" "source_code_hash" {
  template = "${var.skip_zip ? join(",", data.template_file.hash_from_source_code_zip.*.rendered) : join(",", data.archive_file.source_code.*.output_base64sha256)}"
}

data "template_file" "zip_file_path" {
  template = "${var.skip_zip ? var.source_path : join("", data.archive_file.source_code.*.output_path)}"
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
  name               = "${var.name}"
  assume_role_policy = "${data.aws_iam_policy_document.lambda_role.json}"
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
  name   = "${var.name}-logging"
  role   = "${aws_iam_role.lambda.id}"
  policy = "${data.aws_iam_policy_document.logging_for_lambda.json}"
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
