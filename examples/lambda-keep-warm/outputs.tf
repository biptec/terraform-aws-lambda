output "lambda_example_1_function_name" {
  value = "${module.lambda_example_1.function_name}"
}

output "lambda_example_1_function_arn" {
  value = "${module.lambda_example_1.function_arn}"
}

output "lambda_example_2_function_name" {
  value = "${module.lambda_example_2.function_name}"
}

output "lambda_example_2_function_arn" {
  value = "${module.lambda_example_2.function_arn}"
}

output "keep_warm_function_name" {
  value = "${module.keep_warm.function_name}"
}

output "keep_warm_function_arn" {
  value = "${module.keep_warm.function_arn}"
}

output "dynamodb_table_name" {
  value = "${aws_dynamodb_table.example.name}"
}