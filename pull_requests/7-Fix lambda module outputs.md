# Fix lambda module outputs

**brikis98** commented *Oct 10, 2017*

1. Set the `function_name` output to depend on the `aws_lambda_function` resource so code that depends on that output properly wait for the function to be created.

1. Fix a copy/paste error where the same values were passed into the `concat` function multiple times. This caused no outward issues, since we always select one item using the `element` function, but it’s unnecessary/confusing duplication.
<br />
***


