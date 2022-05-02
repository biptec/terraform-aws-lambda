# Lambda S3 example

This folder shows an example of how to use the `lambda` module to create a Lambda function that can read an image from
S3 and return the contents of that image base64 encoded.





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
  "aws_region": "us-east-1",
  "s3_bucket": "lambda-s3-example-images-test",
  "image_filename": "gruntwork-logo.png"
}
```
    
Click "Save and test" and AWS will show you the log output and returned value in the browser.


### Test locally

The code you write for a Lambda function is just regular code with a well-defined entrypoint (the "handler"), so you 
can also run it locally by calling that entrypoint. [test_harness.py](python/test_harness.py) is an example of a simple 
script you can run locally that will execute the handler, decode the base64-encoded image in the return value, and 
write it to disk:

```bash
python python/test_harness.py --region us-east-1 --bucket lambda-s3-example-images-test --filename gruntwork-logo.png
```

See also the [lambda-build example](https://github.com/biptec/terraform-aws-lambda/blob/v0.18.2/examples/lambda-build) to see how you can execute build and packaging steps for
your code before uploading it using Terraform.