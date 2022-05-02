# Error thrown when destroy is called and resources aren't created

**mcalhoun** commented *May 9, 2018*

```
$ cd examples/lambda-build

$ tf apply --auto-approve                                                                                                                                                                                                                                                                                                          
data.archive_file.source_code: Refreshing state...
[remaining output  clipped]
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

$ tf destroy --auto-approve                                                                                                                                                                                                                                                                                        
data.archive_file.source_code: Refreshing state...
data.template_file.source_code_hash: Refreshing state...
[remaining output  clipped]
Destroy complete! Resources: 3 destroyed.

$ tf destroy --auto-approve                                                                                                                                                                                                                                                                                          
data.archive_file.source_code: Refreshing state...
data.template_file.zip_file_path: Refreshing state...
data.template_file.source_code_hash: Refreshing state...
data.aws_iam_policy_document.lambda_role: Refreshing state...
data.aws_iam_policy_document.logging_for_lambda: Refreshing state...

Error: Error applying plan:

2 error(s) occurred:

* module.lambda_s3.output.function_name: element: element() may not be used with an empty list in:

${element(concat(aws_lambda_function.function_in_vpc_code_in_s3.*.function_name, aws_lambda_function.function_in_vpc_code_in_local_folder.*.function_name, aws_lambda_function.function_not_in_vpc_code_in_s3.*.function_name, aws_lambda_function.function_not_in_vpc_code_in_local_folder.*.function_name), 0)}
* module.lambda_s3.output.function_arn: element: element() may not be used with an empty list in:

${element(concat(aws_lambda_function.function_in_vpc_code_in_s3.*.arn, aws_lambda_function.function_in_vpc_code_in_local_folder.*.arn, aws_lambda_function.function_not_in_vpc_code_in_s3.*.arn, aws_lambda_function.function_not_in_vpc_code_in_local_folder.*.arn), 0)}

Terraform does not automatically rollback in the face of errors.
Instead, your Terraform state file has been partially updated with
any resources that successfully completed. Please address the error
above and apply again to incrementally change your infrastructure.
```
<br />
***


**yorinasub17** commented *Oct 29, 2021*

I think this has been resolved through the various terraform upgrades, so going to close this.
***

