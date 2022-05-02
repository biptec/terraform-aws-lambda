# Refactor to consolidate resources

**yorinasub17** commented *Nov 11, 2019*

This consolidates the lambda resources in `modules/lambda` and `modules/lambda-edge`, taking advantage of the TF12 features that allow it.

## Migration Guide

This renames the `aws_lambda_function` resources as a part of consolidating the two versions down to one. As such, you will need to move the resources in the state file in order to avoid downtime.

NOTE: If you are using `terragrunt`, the `state mv` calls should be done using `terragrunt` instead of `terraform`.

### modules/lambda

If you had `var.run_in_vpc = true` and `var.source_path` set:

```
 export MODULE_ADDRESS=module.lambda # This should be the address of the module block used to call `lambda`
terraform state mv "$MODULE_ADDRESS.aws_lambda_function.function_in_vpc_code_in_local_folder[0]" "$MODULE_ADDRESS.aws_lambda_function.function"
```

If you had `var.run_in_vpc = true` and `var.source_path` NOT set:

```
 export MODULE_ADDRESS=module.lambda # This should be the address of the module block used to call `lambda`
terraform state mv "$MODULE_ADDRESS.aws_lambda_function.function_in_vpc_code_in_s3[0]" "$MODULE_ADDRESS.aws_lambda_function.function"
```

If you had `var.run_in_vpc = false` and `var.source_path` set:

``` 
export MODULE_ADDRESS=module.lambda # This should be the address of the module block used to call `lambda`
terraform state mv "$MODULE_ADDRESS.aws_lambda_function.function_not_in_vpc_code_in_local_folder[0]" "$MODULE_ADDRESS.aws_lambda_function.function"
```

If you had `var.run_in_vpc = false` and `var.source_path` NOT set:

```
 export MODULE_ADDRESS=module.lambda # This should be the address of the module block used to call `lambda`
terraform state mv "$MODULE_ADDRESS.aws_lambda_function.function_not_in_vpc_code_in_s3[0]" "$MODULE_ADDRESS.aws_lambda_function.function"
```


### modules/lambda-edge

If you had `var.source_path` set:

``` 
export MODULE_ADDRESS=module.lambda_edge # This should be the address of the module block used to call `lambda-edge`
terraform state mv "$MODULE_ADDRESS.aws_lambda_function.function_not_in_vpc_code_in_local_folder[0]" "$MODULE_ADDRESS.aws_lambda_function.function"
```

If you had `var.source_path` NOT set:

```
 export MODULE_ADDRESS=module.lambda_edge # This should be the address of the module block used to call `lambda-edge`
terraform state mv "$MODULE_ADDRESS.aws_lambda_function.function_not_in_vpc_code_in_s3[0]" "$MODULE_ADDRESS.aws_lambda_function.function"
```


### modules/keep-warm

``` 
export MODULE_ADDRESS=module.keep_warm # This should be the address of the module block used to call `keep-warm`
terraform state mv "$MODULE_ADDRESS.module.keep_warm.aws_lambda_function.function_not_in_vpc_code_in_local_folder[0]" "$MODULE_ADDRESS.module.keep_warm.aws_lambda_function.function"
```
<br />
***


**yorinasub17** commented *Nov 12, 2019*

> Don't forget to mention Terragrunt in migration guide.

Done!

> Sanity check: should lambda and lambda-edge still be separate?

Not sure. Punted investigation for now: https://github.com/gruntwork-io/package-lambda/issues/34
***

**yorinasub17** commented *Nov 12, 2019*

Merging this in. Thanks for the review!
***

