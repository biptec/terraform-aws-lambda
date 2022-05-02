# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE API GATEWAY ACCOUNT LEVEL SETTINGS (CLOUDWATCH)
# This is an example of how to enable CloudWatch log settings for API Gateway in a particular region
# ---------------------------------------------------------------------------------------------------------------------


terraform {
  # This module is now only being tested with Terraform 1.1.x. However, to make upgrading easier, we are setting 1.0.0 as the minimum version.
  required_version = ">= 1.0.0"
}

# ----------------------------------------------------------------------------------------------------------------------
# CONFIGURE AWS CONNECTION
# ----------------------------------------------------------------------------------------------------------------------

provider "aws" {
  # The AWS region in which all resources will be created
  region = var.aws_region
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY THE SERVERS
# ---------------------------------------------------------------------------------------------------------------------

module "api_gateway_account_settings" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:biptec/terraform-aws-lambda.git//modules/api-gateway-account-settings?ref=v0.0.1"
  source = "../../modules/api-gateway-account-settings"

  iam_role_name = var.iam_role_name
}
