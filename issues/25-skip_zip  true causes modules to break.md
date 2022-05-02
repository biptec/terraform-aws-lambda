# skip_zip = true causes modules to break

**ghost** commented *Nov 20, 2018*

I can't allow the module to create a source zip, because the archive_file provider is broken when symlinks are present.  So I wrote my own zip file mechanism, but it turns out that the module doesn't work at all if skip_zip = true.  It blows up with computed count errors.

```
* module.scheduled_shares_lambda.module.lambda.aws_lambda_function.function_not_in_vpc_code_in_s3: aws_lambda_function.function_not_in_vpc_code_in_s3: value of 'count' cannot be computed
* module.scheduled_shares_lambda.module.lambda.data.archive_file.source_code: data.archive_file.source_code: value of 'count' cannot be computed
* module.scheduled_users_lambda.module.lambda.data.archive_file.source_code: data.archive_file.source_code: value of 'count' cannot be computed
* module.scheduled_users_lambda.module.lambda.data.template_file.hash_from_source_code_zip: data.template_file.hash_from_source_code_zip: value of 'count' cannot be computed
* module.scheduled_users_lambda.module.lambda.aws_lambda_function.function_in_vpc_code_in_s3: aws_lambda_function.function_in_vpc_code_in_s3: value of 'count' cannot be computed
* module.scheduled_performance_lambda.module.lambda.data.template_file.hash_from_source_code_zip: data.template_file.hash_from_source_code_zip: value of 'count' cannot be computed
* module.scheduled_users_lambda.module.lambda.aws_lambda_function.function_not_in_vpc_code_in_s3: aws_lambda_function.function_not_in_vpc_code_in_s3: value of 'count' cannot be computed
* module.scheduled_shares_lambda.module.lambda.aws_lambda_function.function_in_vpc_code_in_s3: aws_lambda_function.function_in_vpc_code_in_s3: value of 'count' cannot be computed
* module.scheduled_performance_lambda.module.lambda.aws_lambda_function.function_not_in_vpc_code_in_s3: aws_lambda_function.function_not_in_vpc_code_in_s3: value of 'count' cannot be computed
* module.scheduled_shares_lambda.module.lambda.data.template_file.hash_from_source_code_zip: data.template_file.hash_from_source_code_zip: value of 'count' cannot be computed
* module.scheduled_releases_lambda.module.lambda.data.archive_file.source_code: data.archive_file.source_code: value of 'count' cannot be computed
* module.scheduled_performance_lambda.module.lambda.data.archive_file.source_code: data.archive_file.source_code: value of 'count' cannot be computed
* module.scheduled_releases_lambda.module.lambda.aws_lambda_function.function_not_in_vpc_code_in_s3: aws_lambda_function.function_not_in_vpc_code_in_s3: value of 'count' cannot be computed
* module.scheduled_releases_lambda.module.lambda.data.template_file.hash_from_source_code_zip: data.template_file.hash_from_source_code_zip: value of 'count' cannot be computed
* module.scheduled_releases_lambda.module.lambda.aws_lambda_function.function_in_vpc_code_in_s3: aws_lambda_function.function_in_vpc_code_in_s3: value of 'count' cannot be computed
* module.scheduled_performance_lambda.module.lambda.aws_lambda_function.function_in_vpc_code_in_s3: aws_lambda_function.function_in_vpc_code_in_s3: value of 'count' cannot be computed
```

Looking at that first one, count is computed like this:

```
  count = "${(1 - var.run_in_vpc) * (1 - signum(length(var.source_path)))}"
```

and my calling code looks like this:

```
  run_in_vpc = true
  vpc_id = "${var.vpc_id}"
  subnet_ids = ["${var.subnet_ids}"]

  skip_zip = true
  source_path = "${var.source_path}"
```

both run_in_vpc and skip_zip are specified as constants.  The source_path variable definitely has a non-empty value.
<br />
***


**ghost** commented *Nov 20, 2018*

I wasn't extracting the filename from the external provider correctly - which was tripping the wrong error message.  Gotta love that terraform error handling...
***

