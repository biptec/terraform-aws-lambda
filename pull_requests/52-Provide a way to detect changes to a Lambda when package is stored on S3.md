# Provide a way to detect changes to a Lambda when package is stored on S3

**henare** commented *Sep 24, 2020*

Prior to this change, if you uploaded your Lambda deployment package to
S3 you had no way of letting Terraform know it had changed and that it
should update the Lambda/deploy a new version.

With this change you can explicitly specify the source_code_hash as part
of your module inputs.

So if you've uploaded the package to S3 as part of your Terraform
deployment you can now pass in the filebase64sha256() of that file and
Terraform will correctly detect changes and update the Lambda.

If you don't explicitly specify the source_code_hash then this module
will continue to work as it always has. If you specify a file it will be
directly upload and the hash calculated as part of that. And if you
specify an S3 location then the hash will not be calculated as part of
the deployment (and your Lambda will not update on subsequent deployments).
<br />
***


**brikis98** commented *Sep 24, 2020*

Tests passed. Merging now!
***

**brikis98** commented *Sep 24, 2020*

https://github.com/gruntwork-io/package-lambda/releases/tag/v0.9.1
***

**henare** commented *Sep 24, 2020*

Woohoo, thanks for such a quick review, merge, and release 🌟
***

**brikis98** commented *Sep 25, 2020*

Thank you for the PR! 🍺 
***

