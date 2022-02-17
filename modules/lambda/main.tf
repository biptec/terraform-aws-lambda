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
      version = "< 4.0"
    }
  }
}

# The datasource will actually be used only when referencing an existing IAM entity, otherwise we provide a dummy input
# since `arn` attribute is required, and to avoid using `count`, which might have side effects
data "aws_arn" "role" {
  arn = (
    var.existing_role_arn == null
    ? "arn:aws:iam::123456789012:dummy"
    : var.existing_role_arn
  )
}

locals {
  create_iam_entities = var.create_resources && var.existing_role_arn == null
  role_arn            = length(aws_iam_role.lambda) > 0 ? aws_iam_role.lambda[0].arn : var.existing_role_arn
  # The `aws_arn` datasource returns full resource name, which will have the `role/` prefix in case of IAM role - strip
  # it away, to make compatible with `aws_iam_role.id` attribute
  existing_role_id = trimprefix(data.aws_arn.role.resource, "role/")
  role_id          = length(aws_iam_role.lambda) > 0 ? aws_iam_role.lambda[0].id : local.existing_role_id
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_function" "function" {
  count = var.create_resources ? 1 : 0

  depends_on = [
    # We need this policy to be created before we try to create the lambda job, or you get an error about not having
    # the CreateNetworkInterface permission, which the lambda job needs to work within a VPC.
    aws_iam_role_policy.network_interfaces_for_lambda,

    # Make sure the CloudWatch Log Group is created before creating the function so that Lambda doesn't create a new
    # one.
    aws_cloudwatch_log_group.log_aggregation,
  ]

  function_name = var.name
  description   = var.description
  publish       = var.enable_versioning

  # When source_path is set and image_uri is not set, it indicates that the function should come from the local file path.
  filename         = local.use_local_file ? local.zip_file_path : null
  source_code_hash = local.use_local_file ? local.source_code_hash : null

  # When source_path and image_uri are not set (null), it indicates that the function should come from S3.
  s3_bucket         = var.s3_bucket
  s3_key            = local.use_s3_bucket ? var.s3_key : null
  s3_object_version = local.use_s3_bucket ? var.s3_object_version : null

  # When image_uri is set, it indicates that the function should come from ECR.
  image_uri = var.image_uri

  # When image_uri is specified, runtime, handler and layers should be empty.
  package_type = local.use_docker_image ? "Image" : "Zip"
  runtime      = local.use_docker_image ? null : var.runtime
  handler      = local.use_docker_image ? null : var.handler
  layers       = local.use_docker_image ? [] : var.layers
  timeout      = var.timeout
  memory_size  = var.memory_size
  kms_key_arn  = var.kms_key_arn

  reserved_concurrent_executions = var.reserved_concurrent_executions

  role = local.role_arn

  tags = var.tags

  environment {
    variables = var.environment_variables
  }

  dynamic "vpc_config" {
    # The content of the list does not matter, because we are using this as an on off switch based on the input
    # variable.
    for_each = var.run_in_vpc ? ["use_vpc_config"] : []
    content {
      subnet_ids = var.subnet_ids
      security_group_ids = concat(
        aws_security_group.lambda.*.id,
        var.additional_security_group_ids,
      )
    }
  }

  # Terraform will error if target_arn for dead_letter_config is just nil.
  # Workaround is to dynamically generic this block if the string length for dead_letter_target_arn is not 0.
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn == null ? [] : [1]
    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  # In order to mount a file system, the lambda must also be deployed inside a VPC.
  dynamic "file_system_config" {
    for_each = var.run_in_vpc && var.mount_to_file_system ? ["mount_file_system"] : []
    content {
      arn              = var.file_system_access_point_arn
      local_mount_path = var.file_system_mount_path
    }
  }

  # The Lambda OCI image configurations.
  dynamic "image_config" {
    for_each = local.use_docker_image ? ["once"] : []
    content {
      entry_point       = var.entry_point
      command           = var.command
      working_directory = var.working_directory
    }
  }
}

# Check that only one of the resources (s3, local ip, docker image) is specified.
resource "null_resource" "assert_exactly_one_of" {
  count = length(compact([var.image_uri, var.source_path, var.s3_bucket])) == 1 ? 0 : "ERROR: exactly one of image_uri, source_path, or s3_bucket must be specified."
}

# Local variables which specify which deployment method is used.
locals {
  use_local_file   = var.source_path != null && var.s3_bucket == null && var.image_uri == null
  use_s3_bucket    = var.source_path == null && var.s3_bucket != null && var.image_uri == null
  use_docker_image = var.source_path == null && var.s3_bucket == null && var.image_uri != null
}

# ---------------------------------------------------------------------------------------------------------------------
# ZIP UP THE LAMBDA FUNCTION SOURCE CODE
# Note that if var.skip_zip is true, then we assume that var.source_path is the path to an already-zipped file.
# ---------------------------------------------------------------------------------------------------------------------

data "archive_file" "source_code" {
  count       = var.create_resources && (!var.skip_zip) && var.source_path != null ? 1 : 0
  type        = "zip"
  source_dir  = var.source_path
  output_path = var.zip_output_path == null ? "${path.module}/${var.name}_lambda.zip" : var.zip_output_path
}

locals {
  source_code_hash = (
    var.skip_zip
    ? (var.create_resources ? filebase64sha256(var.source_path) : "")
    : join(",", data.archive_file.source_code.*.output_base64sha256)
  )

  zip_file_path = var.skip_zip ? var.source_path : join("", data.archive_file.source_code.*.output_path)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONALLY CREATE A CLOUDWATCH LOG GROUP FOR THE LAMBDA JOB
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "log_aggregation" {
  count             = var.create_resources && var.should_create_cloudwatch_log_group ? 1 : 0
  name              = "/aws/lambda/${var.name}"
  retention_in_days = var.cloudwatch_log_group_retention_in_days
  kms_key_id        = var.cloudwatch_log_group_kms_key_id
  tags              = var.cloudwatch_log_group_tags
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A SECURITY GROUP FOR THE LAMBDA JOB
# If this lambda function has access to a VPC (var.run_in_vpc is true), we add a security group that controls what
# network traffic can go in and out of the lambda function. We export the id of the security group so users can add
# custom rules.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "lambda" {
  count = var.create_resources && var.run_in_vpc ? 1 : 0

  name        = "${var.name}-lambda"
  description = "Security group for the lambda function ${var.name}"
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_security_group_rule" "allow_outbound_all" {
  count             = var.should_create_outbound_rule ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda[0].id
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN IAM ROLE FOR THE LAMBDA FUNCTION
# This controls what resources the lambda function can access and who can trigger the lambda job. We export the id of
# the IAM role so users can add custom permissions.
# Creating IAM entities is optional and will be skipped if `existing_role_arn` variable is set.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "lambda" {
  count                = local.create_iam_entities ? 1 : 0
  name                 = var.iam_role_name == null ? var.name : var.iam_role_name
  assume_role_policy   = var.assume_role_policy == null ? data.aws_iam_policy_document.lambda_role.json : var.assume_role_policy
  permissions_boundary = var.lambda_role_permissions_boundary_arn

  tags = merge(
    var.iam_role_tags,
    var.tags,
  )
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
  count = (
    local.create_iam_entities && local.use_inline_policies
    ? 1 : 0
  )
  name   = "${var.name}-logging"
  role   = local.role_id
  policy = data.aws_iam_policy_document.logging_for_lambda.json
}

resource "aws_iam_role_policy_attachment" "logging_for_lambda" {
  count = (
    local.create_iam_entities && var.use_managed_iam_policies
    ? 1 : 0
  )
  role       = local.role_id
  policy_arn = aws_iam_policy.logging_for_lambda[0].arn
}

resource "aws_iam_policy" "logging_for_lambda" {
  count = (
    local.create_iam_entities && var.use_managed_iam_policies
    ? 1 : 0
  )
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

    resources = ["arn:aws:logs:*:*:*"]
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GIVE THE LAMBDA FUNCTION PERMISSIONS TO CREATE NETWORK INTERFACES SO IT CAN RUN IN A VPC
# These resources are only created if var.run_in_vpc is true.
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "network_interfaces_for_lambda" {
  count = (
    local.create_iam_entities && var.run_in_vpc && local.use_inline_policies
    ? 1 : 0
  )

  name   = "${var.name}-network-interfaces"
  role   = local.role_id
  policy = data.aws_iam_policy_document.network_interfaces_for_lambda.json
}

resource "aws_iam_role_policy_attachment" "network_interfaces_for_lambda" {
  count = (
    local.create_iam_entities && var.run_in_vpc && var.use_managed_iam_policies
    ? 1 : 0
  )
  role       = local.role_id
  policy_arn = aws_iam_policy.network_interfaces_for_lambda[0].arn
}

resource "aws_iam_policy" "network_interfaces_for_lambda" {
  count = (
    local.create_iam_entities && var.run_in_vpc && var.use_managed_iam_policies
    ? 1 : 0
  )
  name_prefix = "${var.name}-netiface"
  description = "IAM Policy to allow Lambda functions manage Network Interfaces."
  policy      = data.aws_iam_policy_document.network_interfaces_for_lambda.json
}

data "aws_iam_policy_document" "network_interfaces_for_lambda" {
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
