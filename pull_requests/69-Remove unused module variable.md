# Remove unused module variable

**hposca** commented *May 15, 2021*

`source_code_hash` was not being used anywhere in the code.
We realized it because of [this comment](https://github.com/gruntwork-io/terraform-aws-service-catalog/pull/630/files#r617077664) in another PR.

<br />
***


