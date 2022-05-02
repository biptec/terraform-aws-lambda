# Add support for deployment packages in S3

**brikis98** commented *Jun 14, 2017*

This PR updates the lambda package to allow you to create a function from a deployment package that is in S3. 

Unfortunately, Terraform continues to rely heavily on inline blocks, so to wrap this functionality in a reusable module, we now have 4 permutations of the lambda function… Hopefully, there won’t be any more…
<br />
***


**brikis98** commented *Jun 14, 2017*

Merging now. Feedback welcome!
***

**brikis98** commented *Jun 14, 2017*

@anaulin Give https://github.com/gruntwork-io/package-lambda/releases/tag/v0.0.3 a shot.
***

**anaulin** commented *Jun 14, 2017*

I'll give this release a try sometime within this week. Thanks again!
***

