# Perpetual diff

**yorinasub17** commented *Dec 6, 2018*

The modules have a perpetual diff where `plan` will report a diff even though there is no action to be taken. This appears to be coming from the data source dependence on a resource, which terraform defers calculation of until `apply`.
<br />
***


**yorinasub17** commented *Oct 29, 2021*

This has since been resolved. We have a test that validates the perpetual diff now: https://github.com/gruntwork-io/terraform-aws-lambda/blob/master/test/lambda_build_test.go#L59-L63
***

