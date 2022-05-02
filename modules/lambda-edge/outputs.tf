output "function_name" {
  value = aws_lambda_function.function.function_name
}

output "function_arn" {
  value = aws_lambda_function.function.arn
}

output "iam_role_id" {
  value = aws_iam_role.lambda.id
}

output "iam_role_arn" {
  value = aws_iam_role.lambda.arn
}

output "invoke_arn" {
  value = aws_lambda_function.function.invoke_arn
}

output "qualified_arn" {
  value = aws_lambda_function.function.qualified_arn
}

output "version" {
  value = aws_lambda_function.function.version
}
