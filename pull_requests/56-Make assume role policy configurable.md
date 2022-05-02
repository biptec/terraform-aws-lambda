# Make assume role policy configurable

**brikis98** commented *Nov 19, 2020*

Fixes #48.

Apparently, AWS Secrets Manager sometimes needs to assume the IAM role of a Lambda function in order to trigger it for rotating secrets. See https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets-required-permissions.html. This PR makes the entire assume role policy configurable.
<br />
***


**brikis98** commented *Nov 24, 2020*

Thanks for the review! Merging now.
***

**brikis98** commented *Nov 24, 2020*

https://github.com/gruntwork-io/package-lambda/releases/tag/v0.9.4
***

