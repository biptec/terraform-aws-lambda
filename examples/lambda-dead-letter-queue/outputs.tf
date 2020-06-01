output "function_name" {
  value = module.lambda_dlq.function_name
}

output "function_arn" {
  value = module.lambda_dlq.function_arn
}

output "queue_arn" {
  value = module.sqs.queue_arn
}

output "queue_url" {
  value = module.sqs.queue_url
}
