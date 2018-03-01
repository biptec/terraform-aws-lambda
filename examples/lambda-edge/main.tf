# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A LAMBDA FUNCTION TO LOG INCOMING REQUESTS TO A CLOUDFRONT DISTRIBUTION
# Note: this example does NOT yet have the CloudFront triggers integrated! You must enable them manually.
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ---------------------------------------------------------------------------------------------------------------------
# CONFIGURE OUR AWS CONNECTION
# ---------------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "${var.aws_region}"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE LAMBDA FUNCTION
# ---------------------------------------------------------------------------------------------------------------------

module "lambda_edge" {
  source = "../../modules/lambda-edge"

  name = "${var.name}"
  description = "An example of how to interact with CloudFront with Lambda@Edge"

  source_path = "${path.module}/nodejs"
  runtime = "nodejs6.10"
  handler = "index.handler"

  timeout = 30
  memory_size = 128
}
