output "function_name" {
  value = join("", aws_lambda_function.function.*.function_name)
}

output "function_arn" {
  value = join("", aws_lambda_function.function.*.arn)
}

output "iam_role_id" {
  value = join("", aws_iam_role.lambda.*.id)
}

output "iam_role_arn" {
  value = join("", aws_iam_role.lambda.*.arn)
}

// Will only show up if var.run_in_vpc is true
output "security_group_id" {
  value = element(concat(aws_security_group.lambda.*.id, [""]), 0)
}

output "invoke_arn" {
  value = join("", aws_lambda_function.function.*.invoke_arn)
}

output "qualified_arn" {
  value = join("", aws_lambda_function.function.*.qualified_arn)
}

output "version" {
  value = join("", aws_lambda_function.function.*.version)
}
