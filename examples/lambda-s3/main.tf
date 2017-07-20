# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# CREATE A LAMBDA FUNCTION TO PROCESS IMAGES IN S3
# This function can download an image and return its base64-encoded contents.
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

module "lambda_s3" {
  source = "../../modules/lambda"

  name = "${var.name}"
  description = "An example of how to process images in S3 with Lambda"

  source_path = "${path.module}/python"
  runtime = "python2.7"
  handler = "index.handler"

  timeout = 30
  memory_size = 128
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN S3 BUCKET AND UPLOAD AN IMAGE
# This is used for testing/demonstration
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_s3_bucket" "images" {
  bucket = "${lower(var.name)}-images-test"
}

resource "aws_s3_bucket_object" "gruntwork_logo" {
  bucket = "${aws_s3_bucket.images.id}"
  key = "gruntwork-logo.png"
  source = "${path.module}/images/gruntwork-logo.png"
}

# ---------------------------------------------------------------------------------------------------------------------
# GIVE THE LAMBDA FUNCTION PERMISSIONS TO ACCESS THE S3 BUCKET
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role_policy" "access_s3_bucket" {
  role = "${module.lambda_s3.iam_role_id}"
  policy = "${data.aws_iam_policy_document.access_s3_bucket.json}"
}

data "aws_iam_policy_document" "access_s3_bucket" {
  statement {
    effect = "Allow"
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.images.arn}/*"]
  }
  statement {
    effect = "Allow"
    actions = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.images.arn}"]
  }
}
