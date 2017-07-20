# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A LAMBDA FUNCTION THAT HAS ACCESS TO A VPC
# This example shows how to create a custom VPC and a Lambda function that has access to that VPC.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

module "lambda_function" {
  source = "../../modules/lambda"

  name = "${var.name}"
  description = "An example of how to process images in S3 with Lambda"

  source_path = "${path.module}/javascript"
  runtime = "nodejs6.10"
  handler = "index.handler"

  timeout = 30
  memory_size = 128

  run_in_vpc = true
  vpc_id = "${module.vpc.vpc_id}"
  subnet_ids = ["${module.vpc.private_app_subnet_ids}"]
}

# ---------------------------------------------------------------------------------------------------------------------
# ADD A SECURITY GROUP RULE THAT ALLOWS THE LAMBDA FUNCTION TO MAKE OUTBOUND REQUESTS
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_security_group_rule" "allow_all_outbound" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${module.lambda_function.security_group_id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE A VPC
# We will give the Lambda function access to this VPC. Note that in order for the Lambda function to be able to make
# requests to the public Internet, that VPC must contain a NAT Gateway (as the Gruntwork vpc-app module does).
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source = "git::git@github.com:gruntwork-io/module-vpc.git//modules/vpc-app?ref=v0.1.4"

  vpc_name = "${var.vpc_name}"
  aws_region = "${var.aws_region}"

  cidr_block = "10.0.0.0/18"
  num_nat_gateways = 1
  num_availability_zones = "${length(data.aws_availability_zones.all.names)}"
}

data "aws_availability_zones" "all" {}