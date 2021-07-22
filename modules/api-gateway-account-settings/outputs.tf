output "iam_role_arn" {
  value = element(concat(aws_iam_role.cloudwatch.*.arn, [""]), 0)
}

output "iam_role_name" {
  value = element(concat(aws_iam_role.cloudwatch.*.name, [""]), 0)
}
