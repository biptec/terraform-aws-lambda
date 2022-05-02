# Add ability to attach additional security groups to the lambda function

**yorinasub17** commented *Dec 3, 2021*

<!--
  Have any questions? Check out the contributing docs at https://docs.gruntwork.io/guides/contributing/, or
  ask in this Pull Request and a Gruntwork core maintainer will be happy to help :)
  Note: Remember to add '[WIP]' to the beginning of the title if this PR is still a work-in-progress.
-->

## Description

This exposes a new variable that can be used to associate additional custom security groups to the lambda function.

## TODOs

- [X] Ensure the branch is named correctly with the issue number. e.g: `feature/new-vpc-endpoints-955` or `bug/missing-count-param-434`.
- [X] Update the docs.
- [X] Keep the changes backwards compatible where possible.
- [X] Run the pre-commit checks successfully.
- [X] Run the relevant tests successfully.

## Related Issues

<!--
  Link to the issue that is fixed by this PR (if there is one)
  e.g. Fixes #1234

  Link to an issue that is partially addressed by this PR (if there are any)
  e.g. Addresses #1234

  Link to related issues (if there are any)
  e.g. Related to #1234
-->
Fixes https://github.com/gruntwork-io/terraform-aws-lambda/issues/92
<br />
***


**yorinasub17** commented *Dec 3, 2021*

Tests passed, so will go ahead and merge + release this! Thanks for review!
***

