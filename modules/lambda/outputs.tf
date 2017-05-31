output "function_arn" {
  value = "${element(concat(aws_lambda_function.function_in_vpc.*.arn, aws_lambda_function.function_not_in_vpc.*.arn), 0)}"
}

output "iam_role_id" {
  value = "${aws_iam_role.lambda.id}"
}

output "iam_role_arn" {
  value = "${aws_iam_role.lambda.arn}"
}

// Will only show up if var.run_in_vpc is true
output "security_group_id" {
  value = "${aws_security_group.lambda.id}"
}

output "invoke_arn" {
  value = "${element(concat(aws_lambda_function.function_in_vpc.*.invoke_arn, aws_lambda_function.function_not_in_vpc.*.invoke_arn), 0)}"
}

output "qualified_arn" {
  value = "${element(concat(aws_lambda_function.function_in_vpc.*.qualified_arn, aws_lambda_function.function_not_in_vpc.*.qualified_arn), 0)}"
}

output "version" {
  value = "${element(concat(aws_lambda_function.function_in_vpc.*.version, aws_lambda_function.function_not_in_vpc.*.version), 0)}"
}