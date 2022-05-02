# Add required_providers block to lambda-edge

**seanmacisaac** commented *Aug 13, 2021*

These are required to be in us-east-1 per
https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-edge-how-it-works.html

Add this to prevent terraform 0.15 and above from warning,
similar to https://github.com/gruntwork-io/terraform-aws-security/pull/485/files
<br />
***


**brikis98** commented *Aug 18, 2021*

Tests passed! Merging now.
***

**brikis98** commented *Aug 18, 2021*

https://github.com/gruntwork-io/terraform-aws-lambda/releases/tag/v0.13.3
***

