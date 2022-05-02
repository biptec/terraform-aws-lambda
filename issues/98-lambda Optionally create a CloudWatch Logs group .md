# [lambda] Optionally create a CloudWatch Logs group 

**bwhaley** commented *Dec 16, 2021*

The module currently creates a CloudWatch Logs group implicitly which doesn't allow control over the parameters of the logs group such as logs retention and KMS key. Update the module [as described in the docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) to support optionally creating a CloudWatch Logs group separately from the function call, being sure to pass in `retention_in_days` and [`kms_key_id`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group#kms_key_id).
<br />
***


