output "function_name" {
  value = element(
    concat(
      aws_lambda_function.function_in_vpc_code_in_s3.*.function_name,
      aws_lambda_function.function_in_vpc_code_in_local_folder.*.function_name,
      aws_lambda_function.function_not_in_vpc_code_in_s3.*.function_name,
      aws_lambda_function.function_not_in_vpc_code_in_local_folder.*.function_name,
    ),
    0,
  )
}

output "function_arn" {
  value = element(
    concat(
      aws_lambda_function.function_in_vpc_code_in_s3.*.arn,
      aws_lambda_function.function_in_vpc_code_in_local_folder.*.arn,
      aws_lambda_function.function_not_in_vpc_code_in_s3.*.arn,
      aws_lambda_function.function_not_in_vpc_code_in_local_folder.*.arn,
    ),
    0,
  )
}

output "iam_role_id" {
  value = aws_iam_role.lambda.id
}

output "iam_role_arn" {
  value = aws_iam_role.lambda.arn
}

// Will only show up if var.run_in_vpc is true
output "security_group_id" {
  value = element(concat(aws_security_group.lambda.*.id, [""]), 0)
}

output "invoke_arn" {
  value = element(
    concat(
      aws_lambda_function.function_in_vpc_code_in_s3.*.invoke_arn,
      aws_lambda_function.function_in_vpc_code_in_local_folder.*.invoke_arn,
      aws_lambda_function.function_not_in_vpc_code_in_s3.*.invoke_arn,
      aws_lambda_function.function_not_in_vpc_code_in_local_folder.*.invoke_arn,
    ),
    0,
  )
}

output "qualified_arn" {
  value = element(
    concat(
      aws_lambda_function.function_in_vpc_code_in_s3.*.qualified_arn,
      aws_lambda_function.function_in_vpc_code_in_local_folder.*.qualified_arn,
      aws_lambda_function.function_not_in_vpc_code_in_s3.*.qualified_arn,
      aws_lambda_function.function_not_in_vpc_code_in_local_folder.*.qualified_arn,
    ),
    0,
  )
}

output "version" {
  value = element(
    concat(
      aws_lambda_function.function_in_vpc_code_in_s3.*.version,
      aws_lambda_function.function_in_vpc_code_in_local_folder.*.version,
      aws_lambda_function.function_not_in_vpc_code_in_s3.*.version,
      aws_lambda_function.function_not_in_vpc_code_in_local_folder.*.version,
    ),
    0,
  )
}
