# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A LAMBDA FUNCTION THAT HAS ACCESS TO A VPC
# This example shows how to create a custom VPC and a Lambda function that has access to that VPC.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = ">= 0.12.26"
}

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.aws_region
}

locals {
  fs_path = "jenkins"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

module "lambda_function" {
  # When using these modules in your own templates, you will need to use a Git URL with a ref attribute that pins you
  # to a specific version of the modules, such as the following example:
  # source = "git::git@github.com:biptec/terraform-aws-lambda.git//modules/lambda?ref=v1.0.8"
  source = "../../modules/lambda"

  name        = var.name
  description = "An example of how to process images in S3 with Lambda"

  source_path = "${path.module}/javascript"
  runtime     = "nodejs12.x"
  handler     = "index.handler"

  timeout     = 30
  memory_size = 128

  run_in_vpc = true
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_app_subnet_ids

  # lambda only supports one EFS / access point mount
  mount_to_file_system         = true
  file_system_mount_path       = var.efs_mount_path
  file_system_access_point_arn = "arn:aws:elasticfilesystem:${var.aws_region}:${data.aws_caller_identity.current.account_id}:access-point/${module.efs.access_point_ids[local.fs_path]}"
}

# ---------------------------------------------------------------------------------------------------------------------
# ADD A SECURITY GROUP RULE THAT ALLOWS THE LAMBDA FUNCTION TO MAKE OUTBOUND REQUESTS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.lambda_function.security_group_id
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A VPC
# We will give the Lambda function access to this VPC. Note that in order for the Lambda function to be able to make
# requests to the public Internet, that VPC must contain a NAT Gateway (as the Gruntwork vpc-app module does).
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source = "git::git@github.com:biptec/terraform-aws-vpc.git//modules/vpc-app?ref=v0.6.0"

  vpc_name   = var.vpc_name
  aws_region = var.aws_region

  cidr_block             = "10.0.0.0/18"
  num_nat_gateways       = 1
  num_availability_zones = length(data.aws_availability_zones.all.names)
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN EFS + ACCESS POINT
# We will give the Lambda function access to this EFS. Note that in order for a Lambda function to mount to an EFS,
# it must be deployed inside a VPC, as we have done above.
# ---------------------------------------------------------------------------------------------------------------------

module "efs" {
  source = "git::git@github.com:biptec/terraform-aws-data-storage.git//modules/efs?ref=v0.16.2"

  name       = var.name
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  efs_access_points = {
    jenkins = {
      read_write_access_arns = []
      read_only_access_arns  = []
      posix_user = {
        uid            = 1000
        gid            = 1000
        secondary_gids = []
      },
      root_directory = {
        path        = "/${local.fs_path}"
        owner_uid   = 1000
        owner_gid   = 1000
        permissions = 755
      }
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "all" {}
