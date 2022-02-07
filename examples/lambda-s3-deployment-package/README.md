# Lambda S3 deployment package example

This folder shows an example of how to use the `lambda` module to create a Lambda function from a deployment package 
that is in an S3 bucket. The lambda function itself just returns the exact event object you pass it.





## How do you deploy this example?

To apply the Terraform templates:

1. Install [Terraform](https://www.terraform.io/).
1. Open `variables.tf`, set the environment variables specified at the top of the file, and fill in any other variables that
   don't have a default.
1. Run `terraform get`.
1. Run `terraform plan`.
1. If the plan looks good, run `terraform apply`.




## How do you test the Lambda function?

There are two ways to test the Lambda function once it's deployed:

1. [Test in AWS](#test-in-aws)
1. [Test locally](#test-locally)


### Test in AWS

Open up the [AWS Console UI](https://console.aws.amazon.com/lambda/home), find the function, click the "Test" button, 
and enter test data that looks something like this:
   
```json
{
  "text": "Hello, World"
}
```
    
Click "Save and test" and AWS will show you the log output and returned value in the browser.


### Test locally

The code you write for a Lambda function is just regular code with a well-defined entrypoint (the "handler"), so you 
can also run it locally by calling that entrypoint. [test_harness.py](python/test_harness.py) is an example of a simple 
script you can run locally that will execute the handler and print the result to `stdout`:

```bash
python python/test_harness.py --event '{"text": "Hello, World"}'
```