# Lambda Build example

This folder shows an example of how to package code with dependencies and build steps and then deploy it as a Lambda
function using the `lambda` module. The actual Python code in `index.py` is a simple example that uses an external 
library called [requests](http://docs.python-requests.org/en/master/) to make HTTP requests and returns the results. 

With AWS Lambda, your [deployment package](http://docs.aws.amazon.com/lambda/latest/dg/deployment-package-v2.html) 
(zip file) must contain ALL of the dependencies for your app already bundled within it. Moreover, since Lambda 
functions run on Amazon Linux, all of those dependencies must be compiled specifically for Amazon Linux. This example
creates the deployment package as follows:

1. Build the code using [Docker](https://www.docker.com/), using an [Amazon Linux 
   image](http://docs.aws.amazon.com/AmazonECR/latest/userguide/amazon_linux_container_image.html) as the base image,
   as shown in the example [Dockerfile](python/Dockerfile). This Docker image installs all of your dependencies and 
   source code into the `/usr/src/lambda` folder.

1. When developing and testing locally, you can run your Lambda code directly in the Docker image. You can 
   [mount](https://docs.docker.com/engine/tutorials/dockervolumes/#mount-a-host-directory-as-a-data-volume) the
   `python/src` directory from your host OS into `/usr/src/lambda/src` so that your local changes are visible 
   immediately in the container. 

1. To deploy to AWS, you use `docker cp` to copy the `/usr/src/lambda` folder to a local path (see the [build.sh 
   script](python/build.sh))and then run `terraform apply` to zip up that local path and deploy it to AWS. 





## How do you deploy this example?

First, build the deployment package:

1. Install [Docker](https://www.docker.com/).
1. `./python/build.sh`

Next, deploy the code with Terraform:

1. Install [Terraform](https://www.terraform.io/).
1. Open `vars.tf`, set the environment variables specified at the top of the file, and fill in any other variables that
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
  "url": "http://www.example.com"
}
```
    
Click "Save and test" and AWS will show you the log output and returned value in the browser.


### Test locally

The code you write for a Lambda function is just regular code with a well-defined entrypoint (the "handler"), so you 
can also run it locally by calling that entrypoint. The example Python app includes a `test_harness.py` file that is
configured to allow you to run your code locally. This test harness script is configured as the `ENTRYPOINT` for the 
Docker container, so you can test locally as follows:

```bash
cd python
docker build -t lambda-build-example .
docker run -it --rm lambda-build-example http://www.example.com
```

To avoid having to do a `docker build` every time, you can do all subsequent `docker run` calls with your local `src`
folder mounted as a volume so that the Docker container always sees your latest source code:

```bash
docker run -it --rm -v src:/usr/src/lambda/src lambda-build-example http://www.example.com
```

