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

variable "set_source_code_hash" {
  description = "If set to false, this function will no longer set the source_code_hash parameter, so this module will no longer detect and upload changes to the deployment package. This is primarily useful if you update the Lambda function from outside of this module (e.g., you have scripts that do it separately) and want to avoid a plan diff. Used only if var.source_path is non-empty."
  type        = bool
  default     = true
}

variable "runtime" {
  description = "The runtime environment for the Lambda function (e.g. nodejs, python3.9, java8). See https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime for all possible values."
  type        = string
  default     = null
}

variable "handler" {
  description = "The function entrypoint in your code. This is typically the name of a function or method in your code that AWS will execute when this Lambda function is triggered."
  type        = string
  default     = null
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

variable "security_group_description" {
  description = "A description of what the security group is used for."
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

variable "additional_security_group_ids" {
  description = "A list of Security Group IDs that should be attached to the Lambda function when running in a VPC. Only used if var.run_in_vpc is true."
  type        = list(string)
  default     = []
}

variable "mount_to_file_system" {
  description = "Set to true to mount your Lambda function on an EFS. Note that the lambda must also be deployed inside a VPC (run_in_vpc must be set to true) for this config to have any effect."
  type        = bool
  default     = false
}

variable "file_system_access_point_arn" {
  description = "The ARN of an EFS access point to use to access the file system. Only used if var.mount_to_file_system is true."
  type        = string
  default     = null
}

variable "file_system_mount_path" {
  description = "The mount path where the lambda can access the file system. This path must begin with /mnt/. Only used if var.mount_to_file_system is true."
  type        = string
  default     = null
}

variable "skip_zip" {
  description = "Set to true to skip zip archive creation and assume that var.source_path points to a pregenerated zip archive."
  type        = bool
  default     = false
}

variable "iam_role_tags" {
  description = "A map of tags to apply to the IAM role created for the lambda function. This will be merged with the var.tags parameter. Only used if var.existing_role_arn is null."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to apply to the Lambda function and all resources created in this module."
  type        = map(string)
  default     = {}
}

variable "lambda_role_permissions_boundary_arn" {
  description = "The ARN of the policy that is used to set the permissions boundary for the IAM role for the lambda"
  type        = string
  default     = null
}

variable "assume_role_policy" {
  description = "A custom assume role policy for the IAM role for this Lambda function. If not set, the default is a policy that allows the Lambda service to assume the IAM role, which is what most users will need. However, you can use this variable to override the policy for special cases, such as using a Lambda function to rotate AWS Secrets Manager secrets."
  type        = string
  default     = null
}

variable "iam_role_name" {
  description = "The name to use for the IAM role created for the lambda function. If null, default to the function name (var.name). Only used if var.existing_role_arn is null."
  type        = string
  default     = null
}

variable "existing_role_arn" {
  description = "The ARN of existing IAM role that will be used for the Lambda function. If set, the module will not create any IAM entities and fully relies on caller to provide correct IAM role and its policies. Using the variable allows the module to leverage an existing IAM role - for example, when an account has centralized set of IAM entities, or when deploying same function across multiple AWS region to avoid the module attempting to create duplicate IAM entities."
  type        = string
  default     = null
}

variable "dead_letter_target_arn" {
  description = "The ARN of an SNS topic or an SQS queue to notify when invocation of a Lambda function fails. If this option is used, you must grant this function's IAM role (the ID is outputted as iam_role_id) access to write to the target object, which means allowing either the sns:Publish or sqs:SendMessage action on this ARN, depending on which service is targeted."
  default     = null
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

variable "should_create_outbound_rule" {
  description = "If true, create an egress rule allowing all outbound traffic from Lambda function to the entire Internet (e.g. 0.0.0.0/0)."
  type        = bool
  default     = false
}

variable "image_uri" {
  description = "The ECR image URI containing the function's deployment package. Example: 01234501234501.dkr.ecr.us-east-1.amazonaws.com/image_name:image_tag"
  type        = string
  default     = null
}

variable "entry_point" {
  description = "The ENTRYPOINT for the docker image. Only used if you specify a Docker image via image_uri."
  type        = list(string)
  default     = []
}

variable "command" {
  description = "The CMD for the docker image. Only used if you specify a Docker image via image_uri."
  type        = list(string)
  default     = []
}

variable "working_directory" {
  description = "The working directory for the docker image. Only used if you specify a Docker image via image_uri."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_retention_in_days" {
  description = "The number of days to retain log events in the log group. Refer to https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group#retention_in_days for all the valid values. When null, the log events are retained forever."
  type        = number
  default     = null
}

variable "cloudwatch_log_group_kms_key_id" {
  description = "The ID (ARN, alias ARN, AWS ID) of a customer managed KMS Key to use for encrypting log data."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_tags" {
  description = "Tags to apply on the CloudWatch Log Group, encoded as a map where the keys are tag keys and values are tag values."
  type        = map(string)
  default     = null
}

variable "cloudwatch_log_group_subscription_destination_arn" {
  description = "The ARN of the destination to deliver matching log events to. Kinesis stream or Lambda function ARN. Only applicable if var.should_create_cloudwatch_log_group is true."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_subscription_filter_pattern" {
  description = "A valid CloudWatch Logs filter pattern for subscribing to a filtered stream of log events."
  type        = string
  default     = ""
}

variable "cloudwatch_log_group_subscription_role_arn" {
  description = "ARN of an IAM role that grants Amazon CloudWatch Logs permissions to deliver ingested log events to the destination. Only applicable when var.cloudwatch_log_group_subscription_destination_arn is a kinesis stream."
  type        = string
  default     = null
}

variable "cloudwatch_log_group_subscription_distribution" {
  description = "The method used to distribute log data to the destination. Only applicable when var.cloudwatch_log_group_subscription_destination_arn is a kinesis stream. Valid values are `Random` and `ByLogStream`."
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------------------------------------------------
# BACKWARD COMPATIBILITY FEATURE FLAGS
# The following variables are feature flags to enable and disable certain features in the module. These are primarily
# introduced to maintain backward compatibility by avoiding unnecessary resource creation.
# ---------------------------------------------------------------------------------------------------------------------

variable "should_create_cloudwatch_log_group" {
  description = "When true, precreate the CloudWatch Log Group to use for log aggregation from the lambda function execution. This is useful if you wish to customize the CloudWatch Log Group with various settings such as retention periods and KMS encryption. When false, AWS Lambda will automatically create a basic log group to use."
  type        = bool
  default     = true
}

variable "use_managed_iam_policies" {
  description = "When true, all IAM policies will be managed as dedicated policies rather than inline policies attached to the IAM roles. Dedicated managed policies are friendlier to automated policy checkers, which may scan a single resource for findings. As such, it is important to avoid inline policies when targeting compliance with various security standards."
  type        = bool
  default     = true
}

locals {
  use_inline_policies = var.use_managed_iam_policies == false
}
