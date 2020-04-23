output "event_rule_arn" {
  description = "Cloudwatch Event Rule Arn"
  value       = var.create_resources ? aws_cloudwatch_event_rule.scheduled_lambda_job[0].arn : null
}

output "event_rule_schedule" {
  description = "Cloudwatch Event Rule schedule expression"
  value       = var.create_resources ? aws_cloudwatch_event_rule.scheduled_lambda_job[0].schedule_expression : null
}
