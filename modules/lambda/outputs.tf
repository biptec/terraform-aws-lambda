output "function_name" {
  value = var.create_resources ? aws_lambda_function.function[0].function_name : null
}

output "function_arn" {
  value = var.create_resources ? aws_lambda_function.function[0].arn : null
}

output "iam_role_id" {
  value = var.create_resources ? aws_iam_role.lambda[0].id : null
}

output "iam_role_arn" {
  value = var.create_resources ? aws_iam_role.lambda[0].arn : null
}

// Will only show up if var.run_in_vpc is true
output "security_group_id" {
  value = element(concat(aws_security_group.lambda.*.id, [""]), 0)
}

output "invoke_arn" {
  value = var.create_resources ? aws_lambda_function.function[0].invoke_arn : null
}

output "qualified_arn" {
  value = var.create_resources ? aws_lambda_function.function[0].qualified_arn : null
}

output "version" {
  value = var.create_resources ? aws_lambda_function.function[0].version : null
}
