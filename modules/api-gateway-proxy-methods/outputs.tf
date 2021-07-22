output "root_method_id" {
  description = "ID of the API Gateway method for the root proxy (only created if path_prefix is empty string)."
  value       = length(aws_api_gateway_method.root) > 0 ? aws_api_gateway_method.root[0].id : null
}

output "root_method_http_method" {
  description = "HTTP method of the API Gateway method for the root proxy (only created if path_prefix is empty string)."
  value       = length(aws_api_gateway_method.root) > 0 ? aws_api_gateway_method.root[0].http_method : null
}

output "root_intergration_id" {
  description = "ID of the API Gateway integration for the root method (only created if path_prefix is empty string)."
  value       = length(aws_api_gateway_integration.root_lambda) > 0 ? aws_api_gateway_integration.root_lambda[0].id : null
}

output "path_prefix_root_resource_id" {
  description = "ID of the API Gateway method for the root of the path_prefix resource."
  value       = length(aws_api_gateway_resource.path_prefix_root) > 0 ? aws_api_gateway_resource.path_prefix_root[0].id : null
}

output "path_prefix_root_method_id" {
  description = "ID of the API Gateway method for the root of the path_prefix resource."
  value       = length(aws_api_gateway_method.path_prefix_root) > 0 ? aws_api_gateway_method.path_prefix_root[0].id : null
}

output "path_prefix_root_method_http_method" {
  description = "HTTP method of the API Gateway method for the root of the path_prefix resource."
  value       = length(aws_api_gateway_method.path_prefix_root) > 0 ? aws_api_gateway_method.path_prefix_root[0].http_method : null
}

output "path_prefix_root_integration_id" {
  description = "ID of the API Gateway integration for the root method of the path_prefix resource."
  value       = length(aws_api_gateway_integration.path_prefix_root_lambda) > 0 ? aws_api_gateway_integration.path_prefix_root_lambda[0].id : null
}

output "proxy_resource_id" {
  description = "ID of the API Gateway method for the proxy resource."
  value       = length(aws_api_gateway_resource.proxy) > 0 ? aws_api_gateway_resource.proxy[0].id : null
}

output "proxy_method_id" {
  description = "ID of the API Gateway method for the proxy."
  value       = length(aws_api_gateway_method.proxy) > 0 ? aws_api_gateway_method.proxy[0].id : null
}

output "proxy_method_http_method" {
  description = "HTTP method of the API Gateway method for the proxy."
  value       = length(aws_api_gateway_method.proxy) > 0 ? aws_api_gateway_method.proxy[0].http_method : null
}

output "proxy_integration_id" {
  description = "ID of the API Gateway integration for the proxy method."
  value       = length(aws_api_gateway_integration.proxy_lambda) > 0 ? aws_api_gateway_integration.proxy_lambda[0].id : null
}
