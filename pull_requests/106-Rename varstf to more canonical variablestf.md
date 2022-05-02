# Rename vars.tf to more canonical variables.tf

**yorinasub17** commented *Feb 4, 2022*

<!--
  Have any questions? Check out the contributing docs at https://docs.gruntwork.io/guides/contributing/, or
  ask in this Pull Request and a Gruntwork core maintainer will be happy to help :)
  Note: Remember to add '[WIP]' to the beginning of the title if this PR is still a work-in-progress.
-->

## Description

Title saids it all.

## TODOs

- [x] Ensure the branch is named correctly with the issue number. e.g: `feature/new-vpc-endpoints-955` or `bug/missing-count-param-434`.
- [x] Update the docs.
- [x] Keep the changes backwards compatible where possible.
- [x] Run the pre-commit checks successfully.
- [x] Run the relevant tests successfully.

<br />
***


**gcagle3** commented *Feb 4, 2022*

@yorinasub17 Since this PR renames `vars.tf` to `variables.tf`, the corresponding readme/docs should be updated as well. 

Example reference: https://github.com/gruntwork-io/terraform-aws-lambda/blob/chore/rename-varstf/examples/lambda-build/README.md?plain=1#L39

It looks like the following files have references to "vars.tf" that will need to be updated:

- README.md
- examples/lambda-s3/README.md
- examples/lambda-s3-deployment-package/README.md
- examples/lambda-dead-letter-queue/README.md
- examples/lambda-edge/README.md
- examples/scheduled-lambda-job/README.md
- examples/lambda-keep-warm/README.md
- examples/lambda-build/README.md
- examples/lambda-vpc/README.md
- modules/lambda-edge/README.md
- modules/lambda-edge/README.md
- modules/scheduled-lambda-job/README.md
- modules/keep-warm/README.md
- modules/lambda/README.md
***

**yorinasub17** commented *Feb 4, 2022*

Ah good catch! That has been addressed now in [8d15073](https://github.com/gruntwork-io/terraform-aws-lambda/pull/106/commits/8d15073bda98eecd3bb7cbb8161af6d43550fc97)
***

**yorinasub17** commented *Feb 7, 2022*

Thanks for review! Merging now.
***

