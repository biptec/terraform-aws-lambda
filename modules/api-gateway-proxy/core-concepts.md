# Background

## What is API Gateway?

API Gateway is a fully-managed AWS service that allows you to expose public facing RESTful APIs and WebSocket APIs
without externally exposing your services directly. This includes routing backend HTTP endpoints, AWS Lambda functions,
or other AWS Services. API Gateway also provides monitoring and security as a part of its service, allowing you to
handle these concerns in the gateway without implementing the relevant logic in your code.

You can learn more about it in [the official
documenation](https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html).

## What is the difference between the different endpoint types?

API Gateway supports configuring the endpoint in three distinct modes:

- `EDGE`: Globally optimized endpoint that leverages CloudFront to facilitate client access typically from across AWS
  Regions. Connections are first routed to CloudFront (which may or not have caching depending on the configuration of
  the API Gateway methods and integrations) before being routed to the actual API Gateway endpoint.
- `REGIONAL`: Regionally optimized endpoint that directly routes to the API Gateway deployed in the configured region.
- `PRIVATE`: Endpoint that is exposed through a VPC endpoint and is only accessible within the configured VPC.

You can configure the specific endpoint type to expose your API Gateway using the `api_endpoint_configuration` input
variable.


# Operations

## How do I pass in the us_east_1 aws provider?

This module uses `configuration_aliases` to denote the requirement that it requires an `aws` provider that is configured
against the `us-east-1` region (this is necessary for looking up ACM certificates in us-east-1 when configuring the API
Gateway domain). This means that you must provide a `providers` map that sets the `aws.us_east_1` provider alias:

```hcl
provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "api_gateway" {
  source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/api-gateway-proxy?ref=v1.0.8"
  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }

  # ... other attributes are omitted ...
}
```

This is only necessary if you are configuring an EDGE domain. For other cases, the `aws.us_east_1` provider can be
configured to the base `aws` provider.


## How do I expose AWS Lambda functions using API Gateway Proxy?

This module configures the API Gateway to act as a pass through HTTP proxy to the AWS Lambda function. However, API
Gateway supports directly invoking AWS Lambda functions. This means that you don't need to setup a permanent web service
using AWS Lambda: API Gateway fulfills that purpose.

To support this configuration, your AWS Lambda function should be configured as a web app. We recommend using one of the
web frameworks that are optimized for running within AWS Lambda, such as:

- Node.js Express with [serverless-express](https://github.com/vendia/serverless-express)
- Python Django or Flask with [serverless-wsgi](https://github.com/logandk/serverless-wsgi) (refer to [usage without
  Serverless](https://github.com/logandk/serverless-wsgi#usage-without-serverless) for an example of how to use it
  without the Serverless Framework)


## Can I expose additional lambda functions in a decentralized manner?

The `lambda_functions` input of this module allows you to configure routing to multiple lambda functions from a single
API Gateway endpoint. However, you may want to decentralize the management of the API Gateway endpoint, for example so
that your individual lambda service modules will manage the proxy configurations.

To support this, you can use [the api-gateway-proxy-methods](../api-gateway-proxy-methods) module to append additional
lambda function proxies to the REST API created using this module.

The following example shows you how you can use the `api-gateway-proxy-methods` outside of the `api-gateway-proxy`
module to configure the lambda function proxy:

```hcl
module "api_gateway" {
  source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/api-gateway-proxy?ref=v1.0.8"

  # Don't configure any proxies internally
  lambda_functions = {}

  # ... other arguments omitted for brevity ...
}

module "lambda_proxy" {
  source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/api-gateway-proxy-methods?ref=v1.0.8"

  api_gateway_rest_api = module.api_gateway.rest_api
  lambda_function_name = "foo"
}
```
