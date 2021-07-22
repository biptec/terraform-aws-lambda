# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator when calling this terraform module.
# ---------------------------------------------------------------------------------------------------------------------

variable "api_gateway_rest_api" {
  description = "The API Gateway REST API resource as returned by the terraform resource or data source. This can also be able arbitrary object that has the keys id, root_resource_id, and execution_arn of the API Gateway REST API."

  # Ideally we can define an object type, but that would require defining every attribute of the API Gateway REST API
  # resource, which can be painful if you can't pass through the entire resource (e.g., as in terragrunt dependencies).
  type = any
}

variable "lambda_function_name" {
  description = "Name of the AWS Lambda function that is being invoked for the API requests."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL MODULE PARAMETERS
# These variables have defaults, but may be overridden by the operator.
# ---------------------------------------------------------------------------------------------------------------------

variable "path_prefix" {
  # MAINTAINER'S NOTE: Due to a terraform limitation, we can currently only support a single resource level. API Gateway
  # requires you to construct aws_api_gateway_resource resources for each path part. This means that to implement
  # multi-level path routing at API Gateway, we have to construct a linked list of aws_api_gateway_resource resources,
  # which is impossible to express using HCL.
  description = "The URL path prefix to proxy. Requests to any path under this path prefix will be routed to the lambda function. Note that if the path prefix is empty string (default), all requests (including to the root path) will be proxied. Note that this only supports single levels for now (e.g., you can configure to route `foo` and everything below that path like `foo/api/v1`, but you cannot configure to route something like `api/foo/*`). Example: api will route all requests under api/, such as /api, /api/v1, /api/v2/myresource/action, etc."
  type        = string
  default     = ""
}

variable "root_only" {
  description = "Configures only the root path to route to the lambda function, and not the other subpaths. When true, the path_prefix must be empty string or no resources will be created."
  type        = bool
  default     = false
}
