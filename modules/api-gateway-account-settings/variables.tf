variable "iam_role_name" {
  description = "The name of the IAM role that will be created to grant API Gateway rights to cloudwatch"
  type        = string
  default     = "api_gateway_cloudwatch_global"
}

variable "create_resources" {
  description = "Set to false to have this module create no resources. This weird parameter exists solely because Terraform does not support conditional modules. Therefore, this is a hack to allow you to conditionally decide if the API Gateway account settings should be created or not."
  type        = bool
  default     = true
}
