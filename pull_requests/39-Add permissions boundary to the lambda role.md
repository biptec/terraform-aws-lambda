# Add permissions boundary to the lambda role

**hoop33** commented *Feb 25, 2020*

Our deployer user can't create roles without attaching a specific permissions boundary. This PR is to allow setting that permissions boundary.
<br />
***


**brikis98** commented *Feb 26, 2020*

Doh, tests failed with:

```
TestLambdaEdge 2020-02-26T09:36:51Z command.go:121: [1m[31mError: [0m[0m[1mError creating Lambda function: InvalidParameterValueException: The runtime parameter of nodejs8.10 is no longer supported for creating or updating AWS Lambda functions. We recommend you use the new runtime (nodejs12.x) while creating or updating functions.
TestLambdaEdge 2020-02-26T09:36:51Z command.go:121: {
TestLambdaEdge 2020-02-26T09:36:51Z command.go:121:   Message_: "The runtime parameter of nodejs8.10 is no longer supported for creating or updating AWS Lambda functions. We recommend you use the new runtime (nodejs12.x) while creating or updating functions.",
TestLambdaEdge 2020-02-26T09:36:51Z command.go:121:   Type: "User"
TestLambdaEdge 2020-02-26T09:36:51Z command.go:121: }[0m
TestLambdaEdge 2020-02-26T09:36:51Z command.go:121: 
TestLambdaEdge 2020-02-26T09:36:51Z command.go:121: [0m  on ../../modules/lambda-edge/main.tf line 24, in resource "aws_lambda_function" "function":
TestLambdaEdge 2020-02-26T09:36:51Z command.go:121:   24: resource "aws_lambda_function" "function" [4m{[0m
```

I've submitted a PR to fix this issue: https://github.com/gruntwork-io/package-lambda/pull/40
***

**brikis98** commented *Feb 26, 2020*

OK, https://github.com/gruntwork-io/package-lambda/pull/40 is now merged. Could you rebase on the latest from `master`? 
***

**hoop33** commented *Feb 26, 2020*

Rebase complete. Let me know if there are any issues -- thanks!
***

**yorinasub17** commented *Feb 26, 2020*

Thanks! Kicked off another build
***

**yorinasub17** commented *Feb 26, 2020*

Ok build passed so will go ahead to merge this. Thanks for your contribution!
***

