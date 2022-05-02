# API Gateway Proxy Module

[![Maintained by Gruntwork.io](https://img.shields.io/badge/maintained%20by-gruntwork.io-%235849a6.svg)](https://gruntwork.io/?ref=repo_aws_serverless)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.1.0-blue.svg)

This module creates an [API Gateway](https://aws.amazon.com/api-gateway/) that can be used to expose your serverless
applications running in [AWS Lambda](https://aws.amazon.com/lambda/).

This module configures API Gateway to proxy all requests to the underlying Lambda function with basic path-based routing
(but no control over HTTP method based routing, or other details). The Lambda function can contain any code that handles
the requests from API Gateway: e.g., you can use a full web framework like Express, or you can write a handler with your
own route handling logic, or whatever else you want.

This module does not provide a way to define individual routes, methods, etc in the API Gateway. If you need more
control over the API Gateway settings, consider using [the Serverless framework](https://www.serverless.com/). We
recommend using a framework like Serverless to avoid the verbose configuration of routing for API Gateway in Terraform.


![Serverless architecture](https://github.com/biptec/terraform-aws-lambda/blob/v0.18.4/_docs/serverless-architecture.png?raw=true)

**NOTE:** This module specifies `configuration_aliases`, requiring an `aws` provider configured for the `us-east-1`
region with the alias `us_east_1` to be provided.


## Features

* Expose serverless applications using API Gateway
* Proxy all requests from the gateway to the underlying applications


## Learn

This repo is a part of [the Gruntwork Infrastructure as Code Library](https://gruntwork.io/infrastructure-as-code-library/),
a collection of reusable, battle-tested, production ready infrastructure code. If you've never used the Infrastructure as Code Library
before, make sure to read [How to use the Gruntwork Infrastructure as Code Library](https://gruntwork.io/guides/foundations/how-to-use-gruntwork-infrastructure-as-code-library/)!

### Core concepts

* [What is API Gateway?](./core-concepts.md#what-is-api-gateway)
* [What is the difference between the different endpoint
  types?](./core-concepts.md#what-is-the-difference-between-the-different-endpoint-types)
* [API Gateway Documentation](https://docs.aws.amazon.com/apigateway/latest/developerguide/welcome.html): Amazon's docs
  on API Gateway covering core concepts such as security, monitoring, and invoking APIs.

### Repo organization

* [modules](https://github.com/biptec/terraform-aws-lambda/blob/v0.18.4/modules): the main implementation code for this repo, broken down into multiple standalone, orthogonal submodules.
* [examples](https://github.com/biptec/terraform-aws-lambda/blob/v0.18.4/examples): This folder contains working examples of how to use the submodules.
* [test](https://github.com/biptec/terraform-aws-lambda/blob/v0.18.4/test): Automated tests for the modules and examples.




## Deploy

If you just want to try this repo out for experimenting and learning, check out the following resources:

* [examples folder](https://github.com/biptec/terraform-aws-lambda/blob/v0.18.4/examples): The `examples` folder contains sample code optimized for learning, experimenting, and testing (but not production usage).


## Manage

### Day-to-day operations

* [How do I expose AWS Lambda functions using API
  Gateway?](./core-concepts.md#how-do-i-expose-aws-lambda-functions-using-api-gateway)
* [Can I expose additional lambda functions in a decentralized
  manner?](./core-concepts.md#can-i-expose-additional-lambda-functions-in-a-decentralized-manner)
* [How do I pass in the us_east_1 aws provider?](./core-concepts.md#how-do-i-pass-in-the-us_east_1-aws-provider)



## Support

If you need help with this repo or anything else related to infrastructure or DevOps, Gruntwork offers [Commercial Support](https://gruntwork.io/support/) via Slack, email, and phone/video. If you're already a Gruntwork customer, hop on Slack and ask away! If not, [subscribe now](https://www.gruntwork.io/pricing/). If you're not sure, feel free to email us at [support@gruntwork.io](mailto:support@gruntwork.io).




## Contributions

Contributions to this repo are very welcome and appreciated! If you find a bug or want to add a new feature or even contribute an entirely new module, we are very happy to accept pull requests, provide feedback, and run your changes through our automated test suite.

Please see [Contributing to the Gruntwork Infrastructure as Code Library](https://gruntwork.io/guides/foundations/how-to-use-gruntwork-infrastructure-as-code-library/#contributing-to-the-gruntwork-infrastructure-as-code-library) for instructions.




## License

Please see [LICENSE](./LICENSE) for details on how the code in this repo is licensed.
