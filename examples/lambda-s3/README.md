# Lambda S3 example

This folder shows an example of how to use the `lambda` module to create a Lambda function that can read an image from
S3 and return the contents of that image base64 encoded.





## How do you run this example?

To apply the Terraform templates:

1. Install [Terraform](https://www.terraform.io/).
1. Open `vars.tf`, set the environment variables specified at the top of the file, and fill in any other variables that
   don't have a default.
1. Run `terraform get`.
1. Run `terraform plan`.
1. If the plan looks good, run `terraform apply`.
