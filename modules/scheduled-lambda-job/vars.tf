# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# These variables must be passed in by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "lambda_function_name" {
  description = "The name of the lambda function."
  type        = string
}

variable "lambda_function_arn" {
  description = "The ARN of the lambda function."
  type        = string
}

variable "schedule_expression" {
  description = "An expression that defines the schedule for this lambda job. For example, cron(0 20 * * ? *) or rate(5 minutes)."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "namespace" {
  description = "The namespace to use for all resources created by this module. If not set, var.lambda_function_name, with '-scheduled' as a suffix, is used."
  type        = string
  default     = null
}

variable "create_resources" {
  description = "Set to false to have this module skip creating resources. This weird parameter exists solely because Terraform does not support conditional modules. Therefore, this is a hack to allow you to conditionally decide if this module should create anything or not."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to apply to the event rule."
  type        = map(string)
  default     = {}
}
