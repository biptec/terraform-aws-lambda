# Support for docker image lambda

**ryfeus** commented *Apr 1, 2021*

It looks like terraform now supports using Docker image as package for lambdas ([documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function#image_uri)). Looks like the main variables are:
- [image_uri](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function#image_uri)
- [image_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function#image_config)
- [package_type](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function#package_type)

Would it be possible to add support for newer `aws_lambda_function` module?

Thanks.
<br />
***


**brikis98** commented *Apr 2, 2021*

Ah, good point! Yes, that's worth adding. We're a bit buried at the moment; would you be up for a quick PR to add this by any chance?
***

**ryfeus** commented *Apr 2, 2021*

@brikis98 Sounds good. I will make the PR.
***

**ryfeus** commented *Apr 5, 2021*

@brikis98 here is the PR https://github.com/gruntwork-io/terraform-aws-lambda/pull/65.
***

**brikis98** commented *Apr 16, 2021*

Fixed in #65 and released in https://github.com/gruntwork-io/terraform-aws-lambda/releases/tag/v0.10.1.
***

