# Fix CloudWatch log group name for lambda@edge functions

**jeffreymlewis** commented *Feb 25, 2022*

**Describe the bug**
The `lambda-edge` module creates a CloudWatch log group with the incorrect name.

**To Reproduce**
To reproduce, simply deploy a lambda@edge function using this module, and you will see the resulting CloudWatch log group is not prepended with the region name.

**Expected behavior**
According to the [AWS CloudWatch metrics and logs for Lambda@Edge functions](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-cloudwatch-metrics-logging.html) documentation,

> Lambda creates CloudWatch Logs log streams in the AWS Regions closest to the location where the function is executed. The log group name is formatted as: /aws/lambda/us-east-1.function-name, where function-name is the name that you gave to the function when you created it.

In-other-words, the string `us-east-1.` needs to be prepended to the log group name.

**Nice to have**
None

**Additional context**
None
<br />
***


**jeffreymlewis** commented *Feb 25, 2022*

This is a simple fix. I'll submit a PR shortly.
***

