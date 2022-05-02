# Make environment variables optional.

**josh-padnick** commented *Feb 14, 2018*

A customer wanted to use a Lambda for [Lambda@Edge](https://docs.aws.amazon.com/lambda/latest/dg/lambda-edge.html), which apparently requires that no env vars be used. This PR is an attempt to allow that without creating multiple `aws_lambda_function` resources. Unfortunately, this is a breaking change because the `environment_variables` variable now expects a list of maps, not a map of env vars.
<br />
***


**josh-padnick** commented *Feb 14, 2018*

Alright, this is now fully backwards-compatible based on the excellent suggestion from @brikis98!
***

**josh-padnick** commented *Feb 15, 2018*

Ok, all tests passing, but we don't have a Lambda@Edge use case that confirms that no env vars works as expected, so I'm thinking I should wait for the customer to confirm that this PR meets their needs before merging.
***

**josh-padnick** commented *Nov 11, 2019*

This change seems helpful, but it needs to be re-tested and merge conflicts need to be resolved. My vote is to close it with the understanding that this may well be a valid feature to merge, but not something that appears to be worth prioritizing right now.
***

**Etiene** commented *Feb 24, 2022*

Closing stale PR, specially given issue has been addressed at pr #11 
***

