output "url" {
  value = var.domain_name == null ? module.api_gateway.url : "https://${var.domain_name}"
}
