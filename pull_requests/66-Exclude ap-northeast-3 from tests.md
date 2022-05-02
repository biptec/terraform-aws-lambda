# Exclude ap-northeast-3 from tests

**brikis98** commented *Apr 15, 2021*

We are getting test failures in `ap-northeast-3` with an error like this:

```
TestLambdaKeepWarm1 2021-04-15T12:03:50Z logger.go:66: [1m[31mError: [0m[0m[1merror getting Lambda Function (TestLambdaKeepWarm1-0BqkHt-example-2) code signing config AccessDeniedException:
TestLambdaKeepWarm1 2021-04-15T12:03:50Z logger.go:66: 	status code: 403, request id: 6ec8a60a-ebd7-4e21-8c86-eef53edef24b[0m
```

As best as I can tell, this is a bug in Terraform:

https://github.com/hashicorp/terraform-provider-aws/issues/18328
https://github.com/hashicorp/terraform-provider-aws/issues/16755
<br />
***


**brikis98** commented *Apr 15, 2021*

Thanks for the review! Merging now.
***

