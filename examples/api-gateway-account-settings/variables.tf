# ---------------------------------------------------------------------------------------------------------------------
# DEFINE OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "iam_role_name" {
  description = "The name of the iam role to be created"
  type        = string
  default     = "api_gateway_cloudwatch_global"
}
