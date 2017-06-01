# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# These variables must be passed in by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the Lambda function. Used to namespace all resources created by this module."
}

variable "source_dir" {
  description = "The path to the directory that contains your Lambda function source code. This code will be zipped up and uploaded to Lambda."
}

variable "runtime" {
  description = "The runtime environment for the Lambda function (e.g. nodejs, python2.7, java8). See https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime for all possible values."
}

variable "handler" {
  description = "The function entrypoint in your code. This is typically the name of a function or method in your code that AWS will execute when this Lambda function is triggered."
}

variable "timeout" {
  description = "The maximum amount of time, in seconds, your Lambda function will be allowed to run. Must be between 1 and 300 seconds."
}

variable "memory_size" {
  description = "The maximum amount of memory, in MB, your Lambda function will be able to use at runtime. Can be set in 64MB increments from 128MB up to 1536MB. Note that the amount of CPU power given to a Lambda function is proportional to the amount of memory you request, so a Lambda function with 256MB of memory has twice as much CPU power as one with 128MB."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "description" {
  description = "A description of what the Lambda function does."
  default = ""
}

variable "environment_variables" {
  description = "A map of environment variables to pass to the Lambda function. AWS will automatically encrypt these with KMS and decrypt them when running the function."
  type = "map"
  # Lambda does not permit you to pass it an empty map of environment variables, so our default value has to contain
  # this totally useless placeholder.
  default = {
    EnvVarPlaceHolder = "Placeholder"
  }
}

variable "enable_versioning" {
  description = "Set to true to enable versioning for this Lambda function. This allows you to use aliases to refer to execute different versions of the function in different environments. Note that an alternative way to run Lambda functions in multiple environments is to version your Terraform code."
  default = false
}

variable "kms_key_arn" {
  description = "A custom KMS key to use to encrypt and decrypt Lambda function environment variables. Leave it blank to use the default KMS key provided in your AWS account."
  default = ""
}

variable "run_in_vpc" {
  description = "Set to true to give your Lambda function access to resources within a VPC."
  default = false
}

variable "vpc_id" {
  description = "The ID of the VPC the Lambda function should be able to access. Only used if var.run_in_vpc is true."
  default = ""
}

variable "subnet_ids" {
  description = "A list of subnet IDs the Lambda function should be able to access within your VPC. Only used if var.run_in_vpc is true."
  type = "list"
  default = []
}

# Due to a bug in Terraform, this is currently disabled: https://github.com/hashicorp/terraform/issues/14961
#
# variable "dead_letter_target_arn" {
#  description = "The ARN of an SNS topic or an SQS queue to notify when invocation of a Lambda function fails. If this option is used, you must grant this function's IAM role (the ID is outputted as iam_role_id) access to write to the target object, which means allowing either the sns:Publish or sqs:SendMessage action on this ARN, depending on which service is targeted."
#  default = ""
#}

variable "zip_dir" {
  description = "A custom path where to create the zip file that contains your source code. Leave blank to use the default location, which will be inside var.source_folder. This module will upload this zip file to AWS lambda."
  default = ""
}