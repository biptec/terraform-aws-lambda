output "url" {
  description = "The URL of the API Gateway that you can use to invoke it."
  value       = "${aws_api_gateway_deployment.proxy.invoke_url}${aws_api_gateway_stage.proxy.stage_name}"
}

output "rest_api" {
  description = "The API Gateway REST API resource. Contains all the attributes returned by the Terraform resource aws_api_gateway_rest_api."
  value       = aws_api_gateway_rest_api.proxy
}

output "deployment" {
  description = "The API Gateway deployment resource. Contains all the attributes returned by the terraform resource aws_api_gateway_deployment."
  value       = aws_api_gateway_deployment.proxy
}

output "stage" {
  description = "The API Gateway stage resource. Contains all the attributes returned by the terraform resource aws_api_gateway_stage."
  value       = aws_api_gateway_stage.proxy
}
