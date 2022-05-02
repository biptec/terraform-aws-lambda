# Allow using existing IAM entities

**ilia-sotnikov-epam** commented *Jul 8, 2021*

Added `role_name` variable indicating a friendly name of existing IAM role that will be used for the Lambda function. If set, the module  will not create any IAM entities and fully relies on caller to provide  correct IAM role and its policies. Using the variable allows the  module to leverage an existing IAM role
Use cases:
- An account has centralized set of IAM entities
- Deploying same function across multiple AWS region to avoid the module attempting to create  duplicate IAM entities
<br />
***


**ilia-sotnikov-epam** commented *Jul 9, 2021*

> Thanks for the PR!

Thanks much for your input - I'm going to incorporate it shortly. Especially `aws_iam_role` data source - thanks for the hint, I wasn't that comfortable using it as well
***

**ilia-sotnikov-epam** commented *Jul 29, 2021*

> > Thanks for the PR!
> 
> Thanks much for your input - I'm going to incorporate it shortly. Especially `aws_iam_role` data source - thanks for the hint, I wasn't that comfortable using it as well

@brikis98 , hopefully I've addressed all the points - please have a look when you'd have a spare minute. Thanks!
***

**ilia-sotnikov-epam** commented *Jul 29, 2021*

> Thanks! Just a few tiny tweaks and this is good to go!

Great recommendations - very much appreciated! Accepted them all
***

**ilia-sotnikov-epam** commented *Aug 3, 2021*

@brikis98, any chance you might give it a look please?
***

**ilia-sotnikov-epam** commented *Aug 9, 2021*

@brikis98 , @yorinasub17 , happy Mon! Any expectations on when it could be reviewed? I'd like to incorporate the changes into our modules when possible. Thanks!
***

**brikis98** commented *Aug 10, 2021*

Sorry for the delay. I was out on vacation! Looking now.

Also, as a side note: you should hopefully never be blocked by us! If you have a local change that has been merged yet, you can point your `source` URLs and `ref` parameters to your fork/branch, and use that until we've had a chance to catch up.
***

**brikis98** commented *Aug 10, 2021*

Looks like pre-commit checks failed:

```
[INFO] Initializing environment for https://github.com/gruntwork-io/pre-commit.
Terraform fmt............................................................Failed
- hook id: terraform-fmt
- exit code: 3

modules/lambda/main.tf
--- old/modules/lambda/main.tf
+++ new/modules/lambda/main.tf
@@ -21,8 +21,8 @@
   role_arn            = length(aws_iam_role.lambda) > 0 ? aws_iam_role.lambda[0].arn : var.existing_role_arn
   # The `aws_arn` datasource returns full resource name, which will have the `role/` prefix in case of IAM role - strip
   # it away, to make compatible with `aws_iam_role.id` attribute
-  existing_role_id    = trimprefix(data.aws_arn.role.resource, "role/")
-  role_id             = length(aws_iam_role.lambda) > 0 ? aws_iam_role.lambda[0].id : local.existing_role_id
+  existing_role_id = trimprefix(data.aws_arn.role.resource, "role/")
+  role_id          = length(aws_iam_role.lambda) > 0 ? aws_iam_role.lambda[0].id : local.existing_role_id
 }
```

Could you run `terraform fmt`?
***

**ilia-sotnikov-epam** commented *Aug 10, 2021*

> Sorry for the delay. I was out on vacation! Looking now.
> 
> Also, as a side note: you should hopefully never be blocked by us! If you have a local change that has been merged yet, you can point your `source` URLs and `ref` parameters to your fork/branch, and use that until we've had a chance to catch up.

Absolutely no worries, sir - nothing is worth intervening with the vacation ;) And the pending PR hasn't been blocking me, I was using the PR branch as the module ref already. Just wanted to pull in a release version instead :)

> Could you run terraform fmt?

omg, I don't believe I missed that part - apologies. Done in d1d6f5f 
***

**brikis98** commented *Aug 11, 2021*

> Absolutely no worries, sir - nothing is worth intervening with the vacation ;) And the pending PR hasn't been blocking me, I was using the PR branch as the module ref already. Just wanted to pull in a release version instead :)

Great to hear!

> 
> > Could you run terraform fmt?
> 
> omg, I don't believe I missed that part - apologies. Done in [d1d6f5f](https://github.com/gruntwork-io/terraform-aws-lambda/commit/d1d6f5f8f656cc38e8121473e0a7b58b3b45656f)

Heh, no worries, happens all the time. I just kicked off tests again!
***

**brikis98** commented *Aug 11, 2021*

Doh, still getting pre-commit errors:

```
[INFO] Initializing environment for https://github.com/gruntwork-io/pre-commit.
Terraform fmt............................................................Failed
- hook id: terraform-fmt
- exit code: 3

modules/lambda/main.tf
--- old/modules/lambda/main.tf
+++ new/modules/lambda/main.tf
@@ -128,7 +128,7 @@
 # ---------------------------------------------------------------------------------------------------------------------
 
 data "archive_file" "source_code" {
-  count       = var.create_resources && (! var.skip_zip) && var.source_path != null ? 1 : 0
+  count       = var.create_resources && (!var.skip_zip) && var.source_path != null ? 1 : 0
   type        = "zip"
   source_dir  = var.source_path
   output_path = var.zip_output_path == null ? "${path.module}/${var.name}_lambda.zip" : var.zip_output_path
```

Note that this repo is on Terraform 1.x... And in Terraform 0.15 and above, I think they changed the formatting rules on `!`. 
***

**ilia-sotnikov-epam** commented *Aug 11, 2021*

> Doh, still getting pre-commit errors:
> 
> ```
> [INFO] Initializing environment for https://github.com/gruntwork-io/pre-commit.
> Terraform fmt............................................................Failed
> - hook id: terraform-fmt
> - exit code: 3
> 
> modules/lambda/main.tf
> --- old/modules/lambda/main.tf
> +++ new/modules/lambda/main.tf
> @@ -128,7 +128,7 @@
>  # ---------------------------------------------------------------------------------------------------------------------
>  
>  data "archive_file" "source_code" {
> -  count       = var.create_resources && (! var.skip_zip) && var.source_path != null ? 1 : 0
> +  count       = var.create_resources && (!var.skip_zip) && var.source_path != null ? 1 : 0
>    type        = "zip"
>    source_dir  = var.source_path
>    output_path = var.zip_output_path == null ? "${path.module}/${var.name}_lambda.zip" : var.zip_output_path
> ```
> 
> Note that this repo is on Terraform 1.x... And in Terraform 0.15 and above, I think they changed the formatting rules on `!`.

Already found and fixed that - thanks!
***

**brikis98** commented *Aug 11, 2021*

Thanks, kicking off tests again!
***

**brikis98** commented *Aug 11, 2021*

https://github.com/gruntwork-io/terraform-aws-lambda/releases/tag/v0.13.2
***

