# Fix CloudWatch log group name for lambda@edge

**jeffreymlewis** commented *Feb 25, 2022*

## Description

For lambda@edge functions, CloudWatch log group names should be prepended with the string 'us-east-1'.

### Documentation

This is a BACKWARD INCOMPATIBLE change. The migration guide will be very similar to the [v0.16.0 release](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-cloudwatch-metrics-logging.html).

## TODOs

Please ensure all of these TODOs are completed before asking for a review.

- [X] Ensure the branch is named correctly with the issue number. e.g: `feature/new-vpc-endpoints-955` or `bug/missing-count-param-434`.
- [X] Update the docs.
- [ ] Keep the changes backward compatible where possible.
- [ ] Run the pre-commit checks successfully.
- [ ] Run the relevant tests successfully.
- [ ] Ensure any 3rd party code adheres with our [license policy](https://www.notion.so/gruntwork/Gruntwork-licenses-and-open-source-usage-policy-f7dece1f780341c7b69c1763f22b1378) or delete this line if its not applicable.


## Related Issues

Fixes #112 
<br />
***


**yorinasub17** commented *Feb 25, 2022*

Build passed, so going to merge this in! Thanks again for your contribution.
***

