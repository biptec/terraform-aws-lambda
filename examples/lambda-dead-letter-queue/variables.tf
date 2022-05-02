# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name for the Lambda function. Used to namespace all resources created by this module."
  type        = string
  default     = "lambda-dead-letter-queue"
}

variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-east-1)"
  type        = string
  default     = "us-east-1"
}
