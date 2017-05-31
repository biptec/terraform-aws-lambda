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