# Allow optional CloudWatch subscription for lambda

**jeffreymlewis** commented *Feb 23, 2022*

## Description

Allow optional CloudWatch subscription filters for `lambda` and `lambda@edge` functions.

### Documentation

None.

## TODOs

- [X] Ensure the branch is named correctly with the issue number. e.g: `feature/new-vpc-endpoints-955` or `bug/missing-count-param-434`.
- [ ] Update the docs.
- [X] Keep the changes backwards compatible where possible.
- [ ] Run the pre-commit checks successfully.
- [ ] Run the relevant tests successfully.
- [ ] Ensure any 3rd party code adheres with our license policy: https://www.notion.so/gruntwork/Gruntwork-licenses-and-open-source-usage-policy-f7dece1f780341c7b69c1763f22b1378
- [ ] _Maintainers Only._ If necessary, release a new version of this repo.
- [ ] _Maintainers Only._ If there were backwards incompatible changes, include a migration guide in the release notes.
- [ ] _Maintainers Only._ Add to the next version of the monthly newsletter (see https://www.notion.so/gruntwork/Monthly-Newsletter-9198cbe7f8914d4abce23dca7b435f43).


## Related Issues

Fixes #110
<br />
***


**Etiene** commented *Feb 25, 2022*

Thanks for the changes 🎉 I kicked off the tests and it's failing at the pre-commit formatting hook though. Could you run `terraform fmt`?

```
modules/lambda-edge/outputs.tf
--- old/modules/lambda-edge/outputs.tf
+++ new/modules/lambda-edge/outputs.tf
@@ -28,5 +28,5 @@
 
 output "cloudwatch_log_group_name" {
   description = "Name of the (optionally) created CloudWatch log group for the lambda function."
-  value = length(aws_cloudwatch_log_group.log_aggregation) > 0 ? aws_cloudwatch_log_group.log_aggregation[0].id : null
+  value       = length(aws_cloudwatch_log_group.log_aggregation) > 0 ? aws_cloudwatch_log_group.log_aggregation[0].id : null
 }
modules/lambda/outputs.tf
--- old/modules/lambda/outputs.tf
+++ new/modules/lambda/outputs.tf
@@ -44,5 +44,5 @@
 
 output "cloudwatch_log_group_name" {
   description = "Name of the (optionally) created CloudWatch log group for the lambda function."
-  value = length(aws_cloudwatch_log_group.log_aggregation) > 0 ? aws_cloudwatch_log_group.log_aggregation[0].id : null
+  value       = length(aws_cloudwatch_log_group.log_aggregation) > 0 ? aws_cloudwatch_log_group.log_aggregation[0].id : null
 }

goimports................................................................Passed

Exited with code exit status 1

```
***

**jeffreymlewis** commented *Feb 25, 2022*

@Etiene said,
> Could you run `terraform fmt`?

I ran fmt in the `lambda` and `lambda-edge` directories. Ready for re-review.
***

**Etiene** commented *Mar 1, 2022*

@jeffreymlewis lovely! thanks, I'm kicking off the tests again now
***

**jeffreymlewis** commented *Mar 2, 2022*

@Etiene said,
> Tests failed due to undeclared reference (the renaming was missing in a couple of places)

Sorry for the typos. I've fixed those references you identified. Ready for testing again.
***

**gcagle3** commented *Mar 2, 2022*

> Sorry for the typos. I've fixed those references you identified. Ready for testing again.

Thanks for taking care of that! We're running the tests again now. 
***

**gcagle3** commented *Mar 2, 2022*

Changes look good and tests are passing. @Etiene what are your thoughts?
***

**jeffreymlewis** commented *Mar 4, 2022*

Hi @Etiene, let me know if anything else is needed here.
***

