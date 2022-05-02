# Keep Warm Module

This is a Lambda function you can use to invoke your other Lambda functions on a scheduled basis to keep those
functions "warm." This is necessary for Lambda functions that require a low response time (e.g., if you're using Lambda
+ API Gateway as a web service), as Lambda functions that have not been executed in a while will be shut down (that is,
the underlying Docker container will be stopped), and the next time that function is executed, you will be faced with
the overhead of starting the function again. This is known as a "cold start" and the overhead can be from a few hundred
milliseconds all the way up to 15 seconds (the latter is mostly for cold start in a VPC). For more info on cold starts,
see:

* [I’m afraid you’re thinking about AWS Lambda cold starts all wrong](https://hackernoon.com/im-afraid-you-re-thinking-about-aws-lambda-cold-starts-all-wrong-7d907f278a4f)
* [Resolving Cold Start️ in AWS Lambda](https://medium.com/@lakshmanLD/resolving-cold-start%EF%B8%8F-in-aws-lambda-804512ca9b61)
* [API Gateway & Lambda & VPC performance](https://www.robertvojta.com/aws-journey-api-gateway-lambda-vpc-performance/)




## How do you use this module?

* See the [root README](https://github.com/biptec/terraform-aws-lambda/blob/master/README.md) for instructions on using Terraform modules.
* See the [lambda-keep-warm example](https://github.com/biptec/terraform-aws-lambda/blob/master/examples/lambda-keep-warm) folder for sample usage.
* See [vars.tf](./vars.tf) for all the variables you can set on this module.

The basic idea is to:

1. Deploy your Lambda functions using the [lambda module](https://github.com/biptec/terraform-aws-lambda/blob/master/modules/lambda):

    ```hcl
    module "lambda_example" {
      source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/lambda?ref=v0.2.2"

      name = "lambda-example"

      # ... other params omitted ...
    }
    ```

1. Deploy this `keep-warm` module, passing it a map where the keys are the ARNs of your other Lambda functions and
   the values are the [event objects](https://docs.aws.amazon.com/lambda/latest/dg/eventsources.html) to send those
   functions when invoking them. You also set the schedule for how often to invoke those functions. For example, to
   invoke a function called `foo` with the event `{"foo": "bar"}` every 5 minutes, you'd set the following parameters:

    ```hcl
    module "keep_warm" {
      source = "git::git@github.com:gruntwork-io/terraform-aws-lambda.git//modules/keep-warm?ref=v0.2.2"

      name = "keep-warm"

      schedule_expression = "rate(5 minutes)"

      function_to_event_map = {
        "${module.lambda_example.function_arn}" = {
          foo = "bar"
        }
      }
    }
    ```




## Concurrency

An important idea to understand is that a cold start happens once for each _concurrent execution_ of your function. If
the same function is executed more than once at roughly the same time, then each of those executions will happen in
a separate Docker container. If this is the first time executing that container in a long time, it will be subject to
a cold start.

Therefore, if your Lambda functions may be executed concurrently, you will need to use the `concurrency` parameter in
this module to tell it to execute your function concurrently and keep multiple containers warm at the same time. For
example, if your Lambda function is idle most of the time, but periodically, traffic spikes and you need to support 5
simultaneous executions of it, you should set `concurrency = 5` in the `keep-warm` module.




## How often should you run this function?

AWS is making rapid changes to Lambda, so it's hard to say exactly how long the underlying Docker containers will be
kept around, but as of May, 2018, it seems that Lambda functions that are inactive for 10 - 15 minutes get shut down.
Therefore, you should probably run the `keep-warm` function every 5-10 minutes, with the appropriate [concurrency
level](#concurrency) for your functions.

