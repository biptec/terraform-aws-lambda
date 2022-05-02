# Support for reserved_concurrent_executions

**AlainODea** commented *Apr 28, 2020*

Add support for the **reserved_concurrent_executions** property on **aws_lambda_function** resources built through this module. Default to -1 or unreserved (the underlying default).

I've added a very basic smoke test to cover this which is a copy pasta of the lambda-s3 test.
<br />
***


**yorinasub17** commented *Apr 29, 2020*

Build passed! Going to merge and release this as is. If you want to take a crack at using a pointer, you can open another PR on top of this one.
***

