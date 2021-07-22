# AWS Lambda Service Path Based Routing with Catch All Path Example

This folder contains an example of how to use the [AWS Lambda module](../../../modules/lambda) to deploy the provided
NodeJS application in [the app folder](../app) as multiple AWS Lambda functions that return different messages, and
expose the function externally to the world using the [API Gateway Proxy module](../../../modules/api-gateway-proxy) with
path based routing.

This module sets up the following path based routing scheme:

- `hello/*` => `hello_lambda` function (only returns `"hello"`)
- `world/*` => `world_lambda` function (only returns `"world"`)
- everything else => `hello_world_lambda` function (only returns `"hello world"`)


## How do you run this example?

To run this example, you need to:

1. Install [Terraform](https://www.terraform.io/).
1. Create a `terraform.tfvars` file to set variables defined in `variables.tf`.
1. `terraform init`.
1. `terraform plan`.
1. If the plan looks good, run `terraform apply`.

When the templates are applied, Terraform will output the URL that corresponds to the deployed API Gateway that you can
use to connect to application.
