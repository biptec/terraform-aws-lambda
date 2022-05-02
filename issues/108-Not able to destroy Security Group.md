# Not able to destroy Security Group

**marinalimeira** commented *Feb 16, 2022*

Here is the snippet that I am using
```
module "dlq_handler" {
  source      = "<URL>/ia-data-analytics/terraform-aws-lambda.git//modules/lambda?ref=v0.16.0"
  name        = "dlq-handler-${local.resource_suffix}"
  image_uri   = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-west-2.amazonaws.com/${var.application}-dead_letter_handler:${var.git_commit_sha}"
  memory_size = 1700
  timeout     = 180
  run_in_vpc  = true
  vpc_id      = var.vpc_id
  subnet_ids  = var.private_subnet_ids
  tags        = local.tags
  environment_variables = {
    MANUAL_DEAD_LETTER_QUEUE_URL = module.manual_dead_letter_sqs.queue_url
  }
}
```
This works perfectly when I create or modify the resource. When I attempt to delete this I am encountering an issue where the security group will not be deleted.
```
module.lambda_function.aws_security_group.lambda[0]: Still destroying... [id=sg-05e0222151afb7ecf, 19m40s elapsed]
module.lambda_function.aws_security_group.lambda[0]: Still destroying... [id=sg-05e0222151afb7ecf, 19m50s elapsed]
module.lambda_function.aws_security_group.lambda[0]: Still destroying... [id=sg-05e0222151afb7ecf, 20m0s elapsed]
module.lambda_function.aws_security_group.lambda[0]: Still destroying... [id=sg-05e0222151afb7ecf, 20m10s elapsed]
module.lambda_function.aws_security_group.lambda[0]: Still destroying... [id=sg-05e0222151afb7ecf, 20m20s elapsed]
module.lambda_function.aws_security_group.lambda[0]: Still destroying... [id=sg-05e0222151afb7ecf, 20m30s elapsed]
module.lambda_function.aws_security_group.lambda[0]: Still destroying... [id=sg-05e0222151afb7ecf, 20m40s elapsed]
module.lambda_function.aws_security_group.lambda[0]: Still destroying... [id=sg-05e0222151afb7ecf, 20m50s elapsed]
module.lambda_function.aws_security_group.lambda[0]: Still destroying... [id=sg-05e0222151afb7ecf, 21m0s elapsed]
```
Has anyone encountered this and know of a fix? Any help with this is greatly appreciated! 
<br />
***


**marinalimeira** commented *Feb 16, 2022*

Can you try to destroy the resource manually? Sometimes there are VPC dependencies that don't let the SG to be destroyed.
***

**yorinasub17** commented *Feb 16, 2022*

This is actually a known issue, and is a problem with AWS APIs when you use Lambda in VPC.

This is caused by how AWS handles VPC networking in AWS lambda functions (this [announcement blog post](https://aws.amazon.com/blogs/compute/announcing-improved-vpc-networking-for-aws-lambda-functions/)). AWS creates a shadow ENI attachment to the Lambda Hyperplane in the VPC that is not managed by AWS APIs, which is garbage collected upon function deletion. The garbage collection can take up to 45 minutes, so Terraform unfortunately has to wait that long before it can actually delete the security group, since the ENI is associated with the Lambda Hyperplan until the garbage collection routine runs, and you can't destroy the security group until the ENI gets culled.

You can read more about it [here](https://github.com/hashicorp/terraform-provider-aws/issues/10044#issuecomment-537761329).

I'll be closing this since this isn't something we can fix in the module.
***

