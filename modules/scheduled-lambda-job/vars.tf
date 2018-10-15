# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# These variables must be passed in by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "lambda_function_name" {
  description = "The name of the lambda function."
}

variable "lambda_function_arn" {
  description = "The ARN of the lambda function."
}

variable "schedule_expression" {
  description = "An expression that defines the schedule for this lambda job. For example, cron(0 20 * * ? *) or rate(5 minutes)."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "namespace" {
  description = "The namespace to use for all resources created by this module. If not set, var.lambda-function_name, with '-scheduled' as a suffix, is used."
  default     = ""
}