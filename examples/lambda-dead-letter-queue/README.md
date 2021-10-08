# Lambda Dead Letter Queue

This folder shows an example of how to configure the dead letter queue config within the `lambda` or `lambda-edge` module.

## How do you run this example?

To apply the Terraform templates:

1. Install [Terraform](https://www.terraform.io/).
1. Open `vars.tf`, set the environment variables specified at the top of the file, and fill in any other variables that
   don't have a default.
1. Run `terraform get`.
1. Run `terraform plan`.
1. If the plan looks good, run `terraform apply`.

## How do you test the Lambda function?

Testing the lambda function and dead letter config once it is deployed must be done using the [AWS CLI](https://aws.amazon.com/cli/)

### Test with AWS CLI

After installing the AWS CLI, run the following command:

```shell
echo '{ "test-name": "my-test", "message": "hello world" }' | base64 > payload.b64
aws lambda invoke --function-name lambda-dead-letter-queue  --invocation-type Event --payload file://payload.b64 response.json
```

Replace `lambda-dead-letter-queue` with the name of the function if needed (the name of the function is provided as an output after running `terraform apply`). The parameter `--invocation-type Event` must be included for async invocation.

Note that the lambda is expected to throw an expection, which will then trigger the dead letter queue. After invoking the lambda, a new message should be waiting in the SQS queue (see the outputs from `terraform apply` for the name of the configured queue).

Checkout [Asynchronous Invocation](https://docs.aws.amazon.com/lambda/latest/dg/invocation-async.html) for more information on invoking lambdas asynchronously, including via API Gateways.

To verify message have been sent to the queue, go to the [SQS Console](https://us-east-2.console.aws.amazon.com/sqs/home), locate the queue, then click on the `Monitoring` tab to view a line graph of inbound messages received.
