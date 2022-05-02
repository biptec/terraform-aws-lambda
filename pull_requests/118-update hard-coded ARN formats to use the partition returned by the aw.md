# update hard-coded ARN formats to use the partition returned by the aw…

**hammondr** commented *Apr 7, 2022*

## Description

Currently, many ARN formats are hard-coded to use the `aws` partition name.  This works on commercial AWS but does not work for other AWS partitions, like GovCloud and other private partitions.  We can make the code more flexible and useful by determining the proper partition from the AWS provider.

### Documentation

Based on a pattern seen in terraform-aws-security/modules/aws-config-multi-region/main.tf

## TODOs

- [x] Ensure the branch is named correctly with the issue number. e.g: `feature/new-vpc-endpoints-955` or `bug/missing-count-param-434`.
- [n/a] Update the docs.
- [x] Keep the changes backward compatible where possible.
- [x] Run the pre-commit checks successfully.
- [ ] Run the relevant tests successfully.

## Related Issues

- Fixes #117 
<br />
***


**gcagle3** commented *Apr 7, 2022*

Changes look good! Kicking off the tests now.
***

**Etiene** commented *Apr 8, 2022*

Now released on [v0.18.3](https://github.com/gruntwork-io/terraform-aws-lambda/releases/tag/v0.18.3)
***

