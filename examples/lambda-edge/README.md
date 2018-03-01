# Lambda@Edge example

This folder shows an example of how to use the `lambda-edge` module to create a Lambda function that logs incoming requests.





## How do you deploy this example?

To apply the Terraform templates:

1. Install [Terraform](https://www.terraform.io/).
1. Open `vars.tf`, set the environment variables specified at the top of the file, and fill in any other variables that
   don't have a default.
1. Run `terraform get`.
1. Run `terraform plan`.
1. If the plan looks good, run `terraform apply`.

We do not yet have the CloudFront trigger automated, so once the example is deployed, you'll have to [configure
the trigger manually](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-add-triggers.html).



## How do you test the Lambda function?

There are two ways to test the Lambda function once it's deployed:

1. [Test in AWS](#test-in-aws)
1. [Test locally](#test-locally)


### Test in AWS

Open up the [AWS Console UI](https://console.aws.amazon.com/lambda/home), find the function, click the "Test" button,
and enter test data that looks something like this (full format available in the
[Lambda@Edge Event Structure documentation](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-event-structure.html)):

```json
{
  "Records": [
    {
      "cf": {
        "config": {
          "distributionId": "EDFDVBD6EXAMPLE",
          "requestId": "MRVMF7KydIvxMWfJIglgwHQwZsbG2IhRJ07sn9AkKUFSHS9EXAMPLE=="
        },
        "request": {
          "clientIp": "2001:0db8:85a3:0:0:8a2e:0370:7334",
          "querystring": "size=large",
          "uri": "/picture.jpg",
          "method": "GET",
          "headers": {
            "host": [
              {
                "key": "Host",
                "value": "d111111abcdef8.cloudfront.net"
              }
            ],
            "user-agent": [
              {
                "key": "User-Agent",
                "value": "curl/7.51.0"
              }
            ]
          },
          "origin": {
            "custom": {
              "customHeaders": {
                "my-origin-custom-header": [
                  {
                    "key": "My-Origin-Custom-Header",
                    "value": "Test"
                  }
                ]
              },
              "domainName": "example.com",
              "keepaliveTimeout": 5,
              "path": "/custom_path",
              "port": 443,
              "protocol": "https",
              "readTimeout": 5,
              "sslProtocols": [
                "TLSv1",
                "TLSv1.1"
              ]
            },
            "s3": {
              "authMethod": "origin-access-identity",
              "customHeaders": {
                "my-origin-custom-header": [
                  {
                    "key": "My-Origin-Custom-Header",
                    "value": "Test"
                  }
                ]
              },
              "domainName": "my-bucket.s3.amazonaws.com",
              "path": "/s3_path",
              "region": "us-east-1"
            }
          }
        }
      }
    }
  ]
}
```

Click "Save and test" and AWS will show you the log output and returned value in the browser.


### Test locally

The code you write for a Lambda function is just regular code with a well-defined entrypoint (the "handler"), so you
can also run it locally by calling that entrypoint. There are multiple frameworks for local testing NodeJS Lambda functions,
including:
* [Amazon SAM Local](https://docs.aws.amazon.com/lambda/latest/dg/test-sam-local.html)
* [lambda-local](https://www.npmjs.com/package/lambda-local)
