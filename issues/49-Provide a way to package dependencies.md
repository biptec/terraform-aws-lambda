# Provide a way to package dependencies

**rhoboat** commented *Jul 10, 2020*

Right now modules/lambda doesn't provide a way to package dependencies (e.g., npm, pip) with the lambda function.

Two ways we could do this

- We could use the [SAM CLI build](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-build.html) using a `makefile`.
- call a builder function in the terraform module using some injection method
    - [pex module](https://github.com/gruntwork-io/package-terraform-utilities/tree/master/modules/run-pex-as-resource)
    - [download a binary and put it in your $PATH](https://github.com/gruntwork-io/package-terraform-utilities/tree/master/modules/executable-dependency)

We're leaning toward using the SAM CLI because it seem like the more idiomatic approach.
<br />
***


