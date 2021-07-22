# API Gateway Account Settings Module

This folder contains an example of how to use the [api-gateway-account-settings
module](../../modules/api-gateway-account-settings) to configure API Gateway with IAM permissions to report logs and
metrics to CloudWatch for a given region.


## How do you run this example?

To run this example, you need to:

1. Install [Terraform](https://www.terraform.io/).
1. Create a `terraform.tfvars` file to set variables defined in `variables.tf`.
1. `terraform init`.
1. `terraform plan`.
1. If the plan looks good, run `terraform apply`.
