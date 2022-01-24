# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED MODULE PARAMETERS
# These variables must be passed in by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "name" {
  description = "The name for this Lambda function. Also used to namespace the other resources created by this module."
  type        = string
}

variable "function_to_event_map" {
  description = "A map where the keys are the ARNs of Lambda functions to invoke (to keep them warm) and the values are the event objects to send to those functions when invoking them."
  type        = any

  # Example:
  #
  # default = {
  #   "arn:aws:lambda:us-east-1:123456789011:function:my-function-foo" = {}
  #
  #   "arn:aws:lambda:us-east-1:123456789011:function:my-function-bar" = {
  #      foo  = "bar"
  #      blah = 12345
  #   }
  # }
}

variable "schedule_expression" {
  description = "An expression that defines how often to invoke the functions in var.function_to_event_map. For example, cron(0 20 * * ? *) or rate(5 minutes)."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "concurrency" {
  description = "How many concurrent requests to send to each Lambda function in var.function_to_event_map. With Lambda, each concurrent requests to the same function spins up a new container that must be kept warm, so you'll want to set this number to roughly the expected concurrency you see in real-world usage."
  type        = number
  default     = 1
}

# ---------------------------------------------------------------------------------------------------------------------
# BACKWARD COMPATIBILITY FEATURE FLAGS
# The following variables are feature flags to enable and disable certain features in the module. These are primarily
# introduced to maintain backward compatibility by avoiding unnecessary resource creation.
# ---------------------------------------------------------------------------------------------------------------------

variable "use_managed_iam_policies" {
  description = "When true, all IAM policies will be managed as dedicated policies that are attached to the IAM roles. Dedicated managed policies are more friendly to automated policy checkers, which can go through and scan a single resource for findings. As such, it is important to avoid inline policies when targetting compliance with various security standards."
  type        = bool
  default     = true
}

locals {
  use_inline_policies = var.use_managed_iam_policies == false
}
