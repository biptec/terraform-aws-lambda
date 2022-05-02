# Add layers support for the Lambda Function

**josh-taylor** commented *Feb 19, 2019*

Allows Layer ARNs to be passed through to the Lambda function.
<br />
***


**josh-taylor** commented *Feb 20, 2019*

@yorinasub17 Sure. I have used the module locally, essentially using something like this:

```tf
module "test_endpoint_lambda" {
  source = "/Users/joshtaylor/Code/package-lambda//modules/lambda"

  name        = "${local.test_endpoint_post_name}"
  description = "A test endpoint"

  source_path = "${path.module}/hello"
  runtime     = "provided"
  handler     = "hello"
  layers      = ["${var.php_lambda_layers}"]

  run_in_vpc = true
  vpc_id     = "${var.vpc_id}"
  subnet_ids = "${var.subnet_ids}"

  timeout     = 30
  memory_size = 128
}
```

With and without the layers variable. Deploying this to a dev account.
***

**yorinasub17** commented *Feb 20, 2019*

Sounds good! Thanks for sharing. Will merge this in and let the tests run. If they pass, I will cut a release.
***

**yorinasub17** commented *Feb 20, 2019*

Tests passed! Here is the release: https://github.com/gruntwork-io/package-lambda/releases/tag/v0.5.1
***

