# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator when calling this terraform module.
# ---------------------------------------------------------------------------------------------------------------------

variable "api_name" {
  description = "Name of the API Gateway REST API."
  type        = string
}

variable "lambda_functions" {
  # MAINTAINER'S NOTE: Due to a terraform limitation, we can currently only support a single resource level. API Gateway
  # requires you to construct aws_api_gateway_resource resources for each path part. This means that to implement
  # multi-level path routing at API Gateway, we have to construct a linked list of aws_api_gateway_resource resources,
  # which is impossible to express using HCL.
  description = "Map of path prefixes to lambda functions to invoke. Any request that hits paths under the prefix will be routed to the lambda function. Note that this only supports single levels for now (e.g., you can configure to route `foo` and everything below that path like `foo/api/v1`, but you cannot configure to route something like `api/foo/*`). Use empty string for the path prefix if you wish to route all requests, including the root path, to the lambda function. Refer to the example for more info."
  type        = map(string)

  # Examples:
  #
  # Route all requests to the lambda function foo.
  # {
  #   "" = "foo"
  # }
  #
  # Route all requests under apifoo (e.g., apifoo/v1) to the foo lamdba function, and route all requests under apibar (e.g.,
  # apibar/v1) to the bar lambda function.
  # {
  #   "apifoo" = "foo"
  #   "apibar" = "bar"
  # }
}


# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "enable_root_lambda_function" {
  description = "When true, route the root path (URL or URL/) to the lambda function specified by root_lambda_function_name. This is useful when you want to route just the home route to a specific lambda function when configuring path based routing with var.lambda_functions. Conflicts with the catch all lambda function, which is configured using the empty string key in var.lambda_functions. Do not use this to configure a catch all lambda function."
  type        = bool
  default     = false

  # MAINTAINER'S NOTE: Ideally, we would add a validation block to ensure that this is not configured if the user has a
  # catch all route (var.lambda_functions[""] is set), but the terraform variable validation expression does not support
  # looking up other variables in the condition block at this time. So we don't configure variable validation here.
}

variable "root_lambda_function_name" {
  description = "Name of the lambda function to invoke just for the root path (URL or URL/). Only used if enable_root_lambda_function is true."
  type        = string
  default     = null
}

variable "api_description" {
  description = "Description to set on the API Gateway REST API. If empty string, defaults to 'REST API that proxies to lambda function LAMBDA_FUNCTION_NAME'. Set to null if you wish to have an API with no description."
  type        = string
  default     = ""
}

variable "api_endpoint_configuration" {
  description = "Configuration of the API endpoint for the API Gateway REST API. Defaults to EDGE configuration."
  type = object({
    # The endpoint type. Must be one of EDGE, REGIONAL, or PRIVATE.
    type = string
    # Set of VPC Endpoint Identifiers to use when using a private endpoint.
    vpc_endpoint_ids = list(string)
  })
  default = null
}

variable "api_binary_media_types" {
  description = "List of binary media types supported by the REST API. The default only supports UTF-8 encoded text payloads."
  type        = list(string)
  default     = null
}

variable "api_minimum_compression_size" {
  description = "Minimum response size to compress for the REST API. Must be a value between -1 and 10485760 (10MB). Setting a value greater than -1 will enable compression, -1 disables compression (default)."
  type        = number
  default     = null
}

variable "api_key_source" {
  description = "Source of the API key for requests. Valid values are HEADER (default) and AUTHORIZER."
  type        = string
  default     = null
}

variable "enable_execute_api_endpoint" {
  description = "When true, enables the execute-api endpoint. Set to false if you wish for clients to only access the API via the domain set on var.domain_name."
  type        = bool
  default     = true
}

variable "custom_tags" {
  description = "Map of tags (where the key is the tag key and the value is tag value) to apply to the resources in this module."
  type        = map(string)
  default     = {}
}

variable "deployment_description" {
  description = "Description to apply to the API Gateway deployment. This can be useful to identify the API Gateway deployment managed by this module."
  type        = string
  default     = null
}

variable "stage_name" {
  description = "Name of the stage to create with this API Gateway deployment."
  type        = string
  default     = "live"
}

variable "stage_description" {
  description = "Description to set on the stage managed by the stage_name variable."
  type        = string
  default     = null
}

variable "api_settings" {
  description = "Map of HTTP methods (e.g., GET, POST, etc - * for all methods) to the API settings to apply for that method. Refer to the terraform resource docs for available settings: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings#settings."
  # Ideally we would use a concrete object type here, but since Terraform does not yet have reliable optional
  # attributes, we resort to any type here.
  type    = any
  default = {}

  # Example:
  # {
  #   GET = {
  #     metrics_enabled = true
  #     logging_level   = "INFO"
  #   }
  # }
}

variable "force_deployment" {
  description = "When true, force a deployment on every touch. Ideally we can cause a deployment on the API Gateway only when a configuration changes, but terraform does not give reliable mechanisms for triggering a redeployment when any related resource changes. As such, we must either pessimistically redeploy on every touch, or have user control it. You must use the var.deployment_id input variable to trigger redeployments if this is false. Note that setting this to true will, by nature, cause a perpetual diff on the module."
  type        = bool
  default     = true
}

variable "deployment_id" {
  description = "An arbitrary identifier to assign to the API Gateway deployment. Updates to this value will trigger a redeploy of the API Gateway, which is necessary when any underlying configuration changes. This is the only way to trigger a redeployment of an existing API Gateway if force_deployment = false."
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Full domain (e.g., api.example.com) you wish to bind to the API Gateway endpoint. Set to null if you do not wish to bind any domain name."
  type        = string
  default     = null
}

variable "domain_base_path" {
  description = "Path segment that must be prepended to the path when accessing the API via the given domain. If omitted, the API is exposed at the root of the given domain."
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate you wish to use for the bound domain name. When null, the module will look up an issued certificate that is bound to the given domain name, unless var.certificate_domain is set."
  type        = string
  default     = null
}

variable "certificate_domain" {
  description = "The domain to use when looking up the ACM certificate. This is useful for looking up wild card certificates that will match the given domain name."
  type        = string
  default     = null
}

variable "hosted_zone_id" {
  description = "ID of the Route 53 zone where the domain should be configured. If null, this module will lookup the hosted zone using the domain name, or the provided parameters."
  type        = string
  default     = null
}

variable "hosted_zone_tags" {
  description = "Tags to use when looking up the Route 53 hosted zone to bind the domain to. Only used if hosted_zone_id is null."
  type        = map(string)
  default     = {}
}

variable "hosted_zone_domain_name" {
  description = "Domain name to use when looking up the Route 53 hosted zone to bind the API Gateway domain to. Only used if hosted_zone_id is null."
  type        = string
  default     = null
}
