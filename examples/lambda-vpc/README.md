# Lambda VPC example

This folder shows an example of how to use the `lambda` module to create a Lambda function that can access a VPC.





## How do you deploy this example?

To apply the Terraform templates:

1. Install [Terraform](https://www.terraform.io/).
1. Open `vars.tf`, set the environment variables specified at the top of the file, and fill in any other variables that
   don't have a default.
1. Run `terraform get`.
1. Run `terraform plan`.
1. If the plan looks good, run `terraform apply`.





## Known issues

Due to a [bug in Terraform](https://github.com/hashicorp/terraform/issues/10272), if you configure a Lambda function 
with a security group and access to a VPC, `terraform destroy` will fail. The only available workaround at the moment
is to go into the AWS Console, click on "Network Interfaces", and to manually detach and delete the Network Interface
associated with the Lambda function. After that, `terraform destroy` will succeed.