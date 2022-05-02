# Lambda Keep Warm Example

This folder shows an example of how to use the `keep-warm` module to keep your Lambda functions "warm" and avoid
cold starts. See the [keep-warm module](https://github.com/biptec/terraform-aws-lambda/blob/v0.14.1/modules/keep-warm) for more info on cold starts.





## How do you deploy this example?

To apply the Terraform templates:

1. Install [Terraform](https://www.terraform.io/).
1. Open `vars.tf`, set the environment variables specified at the top of the file, and fill in any other variables that
   don't have a default.
1. Run `terraform init`.
1. Run `terraform apply`.

This should deploy two example lambda functions, plus a third one that will invoke the other two on a scheduled basis
to keep them warm.