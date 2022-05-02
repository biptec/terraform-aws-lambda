# Terraform issues "InsufficientRolePermissions" sporadically while running apply

**anupam-rajanish-mf** commented *Apr 16, 2021*

The error:

> error waiting for Lambda Function (<FUNCTION_NAME>) creation: InsufficientRolePermissions: The function's execution role doesn't have permission to perform this operation.

This is a bug we get intermittently when running **apply** the very first time, second and subsequent **apply**'s we do not get this issue.
What has been tried:
- Adding sleep delay with **null_resource** on the attachment of additional IAM policy.
- Attaching the lambda service role: "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole" to the role od lambda function
- Refactoring the code to use **aws_iam_role_policy** with inline policy rather than _aws_iam_policy_ followed by _aws_iam_role_policy_attachment_

Terraform Version: v0.12.30. (Has been tested with v0.13)
Terrgarunt version: v0.24.4

The above issue has been discussed earlier in Gruntwork slack teams.
Associated Slack threads Links:
- 1: https://gruntwork-community.slack.com/archives/CHH9Y3Z62/p1616739354146800
- 2: https://gruntwork-community.slack.com/archives/CHH9Y3Z62/p1615464245312000
- 3: https://gruntwork-io.slack.com/archives/C0164GRE0RW/p1617950931016900

![lambda_error_permission](https://user-images.githubusercontent.com/78875441/114994909-ea7b8000-9eba-11eb-98b2-c8d962071954.PNG)

<br />
***


**pradeep-repaka-mf** commented *Jul 13, 2021*

@ina-stoyanova Any update on this Issue?
***

**ina-stoyanova** commented *Jul 14, 2021*

Hey @pradeep-repaka-mf I don't believe this has been picked up yet. Is this still an active issue for you? Could you share the latest details, if you've got any more?
***

**pradeep-repaka-mf** commented *Jul 14, 2021*

Yes Yesterday my team member got the issue again
***

**marinalimeira** commented *Jul 19, 2021*

Hello @pradeep-repaka-mf, is this blocking you at the moment?

@yorinasub17 suggested some fixes:

- We add an `execution_role_iam_policy` input variable that adds the IAM policies within the module so we can have the function creation wait on those iam policies being attached.
- Add a `function_dependencies` input variable that causes the function creation to wait until those dependencies are materialized. Note that this should only apply to the `aws_lambda_function resource - otherwise, the chicken and egg will be introduced (the IAM role needs to be created before the iam policy can be created, but then the iam role will depend on the iam policy).
- Add a way to provide a custom execution IAM role to the module so that the user can create/manage the IAM role outside the module, and thus have full control over the creation.

We will add this to our maintenance backlog, and give you an update when we start to work on it.
***

**pradeep-repaka-mf** commented *Jul 19, 2021*

@marinalimeira we will wait for the update from you
***

**hposca** commented *Jul 29, 2021*

Hello @anupam-rajanish-mf and @pradeep-repaka-mf ,

I read all the threads you linked and tried to reproduce the issues, but I couldn't. Nevertheless, I was able to generate a similar scenario which may indicate what the actual problem is and, luckily, there is already a readily available solution to it which will hopefully work in your case 😄

**TL;DR:** Can you try using version `v0.12.0` of the `terraform-aws-lambda` module and test if this problem happens again?

---

Explaining the process that I did:

I created a small portion of code that tried to reproduce the issues and, no matter what I tried, I never got the errors that you had.

Trying something similar to the code that you pasted on the last link, as soon as I tried to use a `data "aws_lambda_invocation"` I got a situation in which it only worked if the lambda function was already created and failed super fast when I tried to run everything together:

```
Error: ResourceNotFoundException: Function not found: arn:aws:lambda:us-west-2:738755648600:function:lambda-testing:$LATEST
{
  RespMetadata: {
    StatusCode: 404,
    RequestID: "14130aca-d708-40bc-a2f4-fbc1194a0908"
  },
  Message_: "Function not found: arn:aws:lambda:us-west-2:738755648600:function:lambda-testing:$LATEST",
  Type: "User"
}

  on main.tf line 152, in data "aws_lambda_invocation" "example":
 152: data "aws_lambda_invocation" "example" {
```

Even though this error is not similar to the ones that you posted, it highlighted a similar scenario in which the function that a resource is trying to use is not available yet. So, looking at the changes from [this PR](https://github.com/gruntwork-io/terraform-aws-lambda/pull/75) shipped at [v0.12.0](https://github.com/gruntwork-io/terraform-aws-lambda/releases/tag/v0.12.0), more specifically at the changes on [modules/lambda/outputs.tf](https://github.com/gruntwork-io/terraform-aws-lambda/pull/75/files#diff-5725b9cd061e9af9b8e7babba3bcef62d20e6d222121e2d26033ae7460bf2f96) we can see that the comment specifies a scenario in which the function name was being resolved and returned before the function was actually deployed, which is exactly the scenario I was having here.

After I updated the lambda module to use `v0.12.0` this issue disappeared and I was able to execute everything without problems.
Hopefully, with this change, you'll not have to try workarounds to wait for the lambda creation to associate the permissions anymore.


<details>
<summary>Click to expand -- This is a .patch file with the changes I did that caused the error</summary>


    From b80f6334ae52eeab05629fb3477d00c4d1b3f64e Mon Sep 17 00:00:00 2001
    From: Hugo Posca <hugo@gruntwork.io>
    Date: Thu, 29 Jul 2021 15:59:36 -0700
    Subject: [PATCH 1/2] Trying to reproduce lambda error

    Getting a `Error: ResourceNotFoundException: Function not found` error
    ---
    examples/lambda-build/.terraform-version |   1 +
    examples/lambda-build/main.tf            | 111 ++++++++++++++++++++++-
    examples/lambda-build/vars.tf            |   4 +-
    3 files changed, 113 insertions(+), 3 deletions(-)
    create mode 100644 examples/lambda-build/.terraform-version

    diff --git a/examples/lambda-build/.terraform-version b/examples/lambda-build/.terraform-version
    new file mode 100644
    index 0000000..f98d9c0
    --- /dev/null
    +++ b/examples/lambda-build/.terraform-version
    @@ -0,0 +1 @@
    +0.12.31
    diff --git a/examples/lambda-build/main.tf b/examples/lambda-build/main.tf
    index 2245fad..ed3a375 100644
    --- a/examples/lambda-build/main.tf
    +++ b/examples/lambda-build/main.tf
    @@ -7,6 +7,7 @@ terraform {
      # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
      # forwards compatible with 1.0.x code.
      required_version = ">= 0.12.26"
    +  experiments      = [variable_validation]
    }

    # ---------------------------------------------------------------------------------------------------------------------
    @@ -17,6 +18,70 @@ provider "aws" {
      region = var.aws_region
    }

    +module "vpc_app_example" {
    +  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
    +  # to a specific version of the modules, such as the following example:
    +  source = "git::git@github.com:gruntwork-io/terraform-aws-vpc.git//modules/vpc-app?ref=v0.17.0"
    +
    +  vpc_name   = "lambda-testing"
    +  aws_region = var.aws_region
    +
    +  # The IP address range of the VPC in CIDR notation. A prefix of /16 is recommended. Do not use a prefix higher
    +  # than /27.
    +  cidr_block = "10.0.0.0/16"
    +
    +  # The number of NAT Gateways to launch for this VPC. For production VPCs, a NAT Gateway should be placed in each
    +  # Availability Zone (so likely 3 total), whereas for non-prod VPCs, just one Availability Zone (and hence 1 NAT
    +  # Gateway) will suffice. Warning: You must have at least this number of Elastic IP's to spare.  The default AWS
    +  # limit is 5 per region, but you can request more.
    +  num_nat_gateways = 1
    +
    +  # Some teams want to explicitly define the exact CIDR blocks used by their subnets. If the given var is an empty
    +  # map, the terraform template computes sane defaults.
    +  # - To explicitly declare subnets, initialize the value to a Terraform map whose keys are AZ-0, AZ-1, ... AZ-n, where
    +  #   n is the number of Availability Zones in this region, and whose values are the individual CIDR blocks. For example:
    +  #   public_subnet_cidr_blocks = {
    +  #      AZ-0 = "10.226.20.0/24"
    +  #      AZ-1 = "10.226.21.0/24"
    +  #   }
    +  # - To use the default subnet CIDR blocks, initialize the value to an empty Terraform map. For example:
    +  #   public_subnet_cidr_blocks = {}
    +  # - Be sure to choose subnet CIDR blocks that are actually within the VPC "cidr_block" above.
    +  # NOTE: For testing purposes, we either leave these maps blank or define CIDR blocks up to the maximum number of
    +  # AZ's (4). In real-world usage, you would probably define one CIDR block for each AZ.
    +  public_subnet_cidr_blocks = {
    +    AZ-0 = "10.0.240.0/24"
    +    AZ-1 = "10.0.241.0/24"
    +  }
    +
    +  private_app_subnet_cidr_blocks = {}
    +
    +  private_persistence_subnet_cidr_blocks = {}
    +
    +  custom_tags = {
    +    Foo = "Bar"
    +  }
    +
    +  public_subnet_custom_tags = {
    +    Foo = "Bar-public"
    +  }
    +
    +  private_app_subnet_custom_tags = {
    +    Foo = "Bar-private-app"
    +    Bar = "Baz"
    +  }
    +
    +  private_persistence_subnet_custom_tags = {
    +    Foo = "Bar-private-persistence"
    +    Bar = "Foo"
    +  }
    +
    +  nat_gateway_custom_tags = {
    +    Foo = "Bar-nat-gateway"
    +    Bar = "Foo"
    +  }
    +}
    +
    # ---------------------------------------------------------------------------------------------------------------------
    # CREATE THE LAMBDA FUNCTION
    # ---------------------------------------------------------------------------------------------------------------------
    @@ -25,7 +90,7 @@ module "lambda_s3" {
      # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
      # to a specific version of the modules, such as the following example:
      # source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/lambda?ref=v1.0.8"
    -  source           = "../../modules/lambda"
    +  source           = "git::https://github.com/gruntwork-io/terraform-aws-lambda.git//modules/lambda?ref=v0.10.0"
      create_resources = var.create_resources

      name        = var.name
    @@ -51,4 +116,48 @@ module "lambda_s3" {

      timeout     = 30
      memory_size = 128
    +
    +  run_in_vpc                  = true
    +  vpc_id                      = module.vpc_app_example.vpc_id
    +  subnet_ids                  = module.vpc_app_example.private_app_subnet_ids
    +  should_create_outbound_rule = true
    +}
    +
    +resource "aws_iam_role_policy" "some_policy" {
    +  name = "${var.name}-testing-policy-race-condition"
    +  role = module.lambda_s3.iam_role_id
    +  policy = jsonencode({
    +    Version = "2012-10-17"
    +    Statement = [
    +      {
    +        "Sid" : "GeneratePassword",
    +        Action = [
    +          "secretsmanager:GetRandomPassword",
    +        ]
    +        Effect   = "Allow"
    +        Resource = ["*"]
    +      },
    +    ]
    +  })
    +}
    +
    +resource "aws_lambda_permission" "lambda_permission" {
    +  statement_id  = "SecretsManagerAccess"
    +  action        = "lambda:InvokeFunction"
    +  function_name = module.lambda_s3.function_name
    +  principal     = "secretsmanager.amazonaws.com"
    +}
    +
    +data "aws_lambda_invocation" "example" {
    +  function_name = module.lambda_s3.function_name
    +
    +  input = <<JSON
    +{
    +  "url": "https://www.example.com"
    +}
    +JSON
    +}
    +
    +output "result_entry" {
    +  value = jsondecode(data.aws_lambda_invocation.example.result)
    }
    diff --git a/examples/lambda-build/vars.tf b/examples/lambda-build/vars.tf
    index a3db97b..79625d7 100644
    --- a/examples/lambda-build/vars.tf
    +++ b/examples/lambda-build/vars.tf
    @@ -6,13 +6,13 @@
    variable "name" {
      description = "The name for the Lambda function. Used to namespace all resources created by this module."
      type        = string
    -  default     = "lambda-build-example"
    +  default     = "lambda-testing"
    }

    variable "aws_region" {
      description = "The AWS region to deploy to (e.g. us-east-1)"
      type        = string
    -  default     = "us-east-1"
    +  default     = "us-west-2"
    }

    variable "create_resources" {
    --
    2.25.1


</details>


<details>
<summary>Click to expand -- Update to v0.12.0 fixing the issue</summary>


    From 70cfac5f30d6edcc6bfaec22e48809d341cc4329 Mon Sep 17 00:00:00 2001
    From: Hugo Posca <hugo@gruntwork.io>
    Date: Thu, 29 Jul 2021 16:00:39 -0700
    Subject: [PATCH 2/2] No more errors

    ---
    examples/lambda-build/main.tf | 2 +-
    1 file changed, 1 insertion(+), 1 deletion(-)

    diff --git a/examples/lambda-build/main.tf b/examples/lambda-build/main.tf
    index ed3a375..df4df3c 100644
    --- a/examples/lambda-build/main.tf
    +++ b/examples/lambda-build/main.tf
    @@ -90,7 +90,7 @@ module "lambda_s3" {
      # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
      # to a specific version of the modules, such as the following example:
      # source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/lambda?ref=v1.0.8"
    -  source           = "git::https://github.com/gruntwork-io/terraform-aws-lambda.git//modules/lambda?ref=v0.10.0"
    +  source           = "git::https://github.com/gruntwork-io/terraform-aws-lambda.git//modules/lambda?ref=v0.12.0"
      create_resources = var.create_resources

      name        = var.name
    --
    2.25.1


</details>

Also, to try to be closer to your scenario, I used Terraform `v0.12.31` to test this (at the patch file there is a `.terraform-version` file specifying `0.12.31`).

***

**AlainODea** commented *Oct 19, 2021*

I get the same issue consistently when trying to deploy a new Lambda function:

```
module.lambda.aws_lambda_function.function[0]: Still creating... [30s elapsed]
╷
│ Error: error waiting for Lambda Function (cargo-text-extract) creation: InsufficientRolePermissions: The function's execution role doesn't have permission to perform this operation.
│ 
│   with module.lambda.aws_lambda_function.function[0],
│   on .terraform/modules/lambda/modules/lambda/main.tf line 22, in resource "aws_lambda_function" "function":
│   22: resource "aws_lambda_function" "function" {
│ 
╵
```

When I attach arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole, I am able to apply successfully.

I think there is a bug in the execution role permissions related to changes in AWS's expected permissions for Lambdas.
***

