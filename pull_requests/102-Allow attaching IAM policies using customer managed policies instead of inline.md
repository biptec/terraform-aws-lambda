# Allow attaching IAM policies using customer managed policies instead of inline

**yorinasub17** commented *Jan 20, 2022*

<!--
  Have any questions? Check out the contributing docs at https://docs.gruntwork.io/guides/contributing/, or
  ask in this Pull Request and a Gruntwork core maintainer will be happy to help :)
  Note: Remember to add '[WIP]' to the beginning of the title if this PR is still a work-in-progress.
-->

## Description

<!-- Write a brief description of the changes introduced by this PR -->
Expose the ability to switch between using inline IAM policies, and customer managed IAM policies. Using inline policies are important for compliance checkers because they can be scanned as a single resource, as opposed to additionally scanning IAM users and roles and pulling down the inline policies.


## TODOs

- [x] Ensure the branch is named correctly with the issue number. e.g: `feature/new-vpc-endpoints-955` or `bug/missing-count-param-434`.
- [x] Update the docs.
- [x] Keep the changes backwards compatible where possible.
- [x] Run the pre-commit checks successfully.
- [x] Run the relevant tests successfully.


## Related Issues

<!--
  Link to the issue that is fixed by this PR (if there is one)
  e.g. Fixes #1234

  Link to an issue that is partially addressed by this PR (if there are any)
  e.g. Addresses #1234

  Link to related issues (if there are any)
  e.g. Related to #1234
-->
Fixes https://github.com/gruntwork-io/terraform-aws-lambda/issues/97
<br />
***


**rhoboat** commented *Jan 21, 2022*

Approved, but left a nit on the wording of a description. Up to you!
***

**yorinasub17** commented *Jan 24, 2022*

Thanks for review! I'll merge this in and implement the description as a follow up PR.
***

