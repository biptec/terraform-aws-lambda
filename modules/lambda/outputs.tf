output "function_name" {
  value = (
    length(aws_lambda_function.function) > 0
    ? (
      # We add a tautology here so that the function_name is not outputed until the function is actually created.
      # Otherwise, terraform optimises the output and returns it immediately at plan time because the function_name
      # attribute is based on a variable.
      aws_lambda_function.function[0].arn != null
      ? aws_lambda_function.function[0].function_name
      : aws_lambda_function.function[0].function_name
    )
    : null
  )
}

output "function_arn" {
  value = length(aws_lambda_function.function) > 0 ? aws_lambda_function.function[0].arn : null
}

output "invoke_arn" {
  value = length(aws_lambda_function.function) > 0 ? aws_lambda_function.function[0].invoke_arn : null
}

output "qualified_arn" {
  value = length(aws_lambda_function.function) > 0 ? aws_lambda_function.function[0].qualified_arn : null
}

output "version" {
  value = length(aws_lambda_function.function) > 0 ? aws_lambda_function.function[0].version : null
}

output "iam_role_id" {
  value = local.role_id
}

output "iam_role_arn" {
  value = local.role_arn
}

// Will only show up if var.run_in_vpc is true
output "security_group_id" {
  value = element(concat(aws_security_group.lambda.*.id, [""]), 0)
}
