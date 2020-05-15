# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# These variables must be passed in by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name of the Lambda function. Used to namespace all resources created by this module."
  type        = string
}

variable "source_path" {
  description = "The path to the directory that contains your Lambda function source code. This code will be zipped up and uploaded to Lambda as your deployment package. If var.skip_zip is set to true, then this is assumed to be the path to an already-zipped file, and it will be uploaded directly to Lambda as a deployment package. Exactly one of var.source_path or the var.s3_xxx variables must be specified."
  type        = string
  default     = null
}

variable "zip_output_path" {
  description = "The path to store the output zip file of your source code. If empty, defaults to module path. This should be the full path to the zip file, not a directory."
  type        = string
  default     = null
}

variable "s3_bucket" {
  description = "An S3 bucket location containing the function's deployment package. Exactly one of var.source_path or the var.s3_xxx variables must be specified."
  type        = string
  default     = null
}

variable "s3_key" {
  description = "The path within var.s3_bucket where the deployment package is located. Exactly one of var.source_path or the var.s3_xxx variables must be specified."
  type        = string
  default     = null
}

variable "s3_object_version" {
  description = "The version of the path in var.s3_key to use as the deployment package. Exactly one of var.source_path or the var.s3_xxx variables must be specified."
  type        = string
  default     = null
}

variable "runtime" {
  description = "The runtime environment for the Lambda function (e.g. nodejs, python2.7, java8). See https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime for all possible values."
  type        = string
}

variable "handler" {
  description = "The function entrypoint in your code. This is typically the name of a function or method in your code that AWS will execute when this Lambda function is triggered."
  type        = string
}

variable "layers" {
  description = "The list of Lambda Layer Version ARNs to attach to your Lambda Function. You can have a maximum of 5 Layers attached to each function."
  type        = list(string)
  default     = []
}

variable "timeout" {
  description = "The maximum amount of time, in seconds, your Lambda function will be allowed to run. Must be between 1 and 300 seconds."
  type        = number
}

variable "memory_size" {
  description = "The maximum amount of memory, in MB, your Lambda function will be able to use at runtime. Can be set in 64MB increments from 128MB up to 1536MB. Note that the amount of CPU power given to a Lambda function is proportional to the amount of memory you request, so a Lambda function with 256MB of memory has twice as much CPU power as one with 128MB."
  type        = number
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "description" {
  description = "A description of what the Lambda function does."
  type        = string
  default     = null
}

variable "environment_variables" {
  description = "A map of environment variables to pass to the Lambda function. AWS will automatically encrypt these with KMS and decrypt them when running the function."
  type        = map(string)

  # Lambda does not permit you to pass it an empty map of environment variables, so our default value has to contain
  # this totally useless placeholder.
  default = {
    EnvVarPlaceHolder = "Placeholder"
  }
}

variable "enable_versioning" {
  description = "Set to true to enable versioning for this Lambda function. This allows you to use aliases to refer to execute different versions of the function in different environments. Note that an alternative way to run Lambda functions in multiple environments is to version your Terraform code."
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "A custom KMS key to use to encrypt and decrypt Lambda function environment variables. Leave it blank to use the default KMS key provided in your AWS account."
  type        = string
  default     = null
}

variable "run_in_vpc" {
  description = "Set to true to give your Lambda function access to resources within a VPC."
  type        = bool
  default     = false
}

variable "vpc_id" {
  description = "The ID of the VPC the Lambda function should be able to access. Only used if var.run_in_vpc is true."
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "A list of subnet IDs the Lambda function should be able to access within your VPC. Only used if var.run_in_vpc is true."
  type        = list(string)
  default     = []
}

variable "skip_zip" {
  description = "Set to true to skip zip archive creation and assume that var.source_path points to a pregenerated zip archive."
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to apply to the Lambda function."
  type        = map(string)
  default     = {}
}

variable "lambda_role_permissions_boundary_arn" {
  description = "The ARN of the policy that is used to set the permissions boundary for the IAM role for the lambda"
  type        = string
  default     = null
}

variable "dead_letter_target_arn" {
  description = "The ARN of an SNS topic or an SQS queue to notify when invocation of a Lambda function fails. If this option is used, you must grant this function's IAM role (the ID is outputted as iam_role_id) access to write to the target object, which means allowing either the sns:Publish or sqs:SendMessage action on this ARN, depending on which service is targeted."
  default     = ""
}

variable "create_resources" {
  description = "Set to false to have this module skip creating resources. This weird parameter exists solely because Terraform does not support conditional modules. Therefore, this is a hack to allow you to conditionally decide if this module should create anything or not."
  type        = bool
  default     = true
}

variable "reserved_concurrent_executions" {
  description = "The amount of reserved concurrent executions for this lambda function or -1 if unreserved."
  type        = number
  default     = null
}
