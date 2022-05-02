# Update versions of tools in circleci

**yorinasub17** commented *Mar 10, 2022*

<!--
Have any questions? Check out the contributing docs at https://gruntwork.notion.site/Gruntwork-Coding-Methodology-02fdcd6e4b004e818553684760bf691e,
or ask in this Pull Request and a Gruntwork core maintainer will be happy to help :)
Note: Remember to add '[WIP]' to the beginning of the title if this PR is still a work-in-progress. Remove it when it is ready for review!
-->

## Description

- Update machine image from deprecated ubuntu 16.04 image to ubuntu 20.04
- Update docker image from deprecated `circleci/python` image to `cimg/python`
- Update precommit job to use `small` resource class
- Update test utilities versions
- Update merge syntax in yaml to the proper one (from [the yaml spec](https://yaml.org/type/merge.html)),
<!-- Important: Did you make any backward incompatible changes? If yes, then you must write a migration guide! -->

## TODOs

Please ensure all of these TODOs are completed before asking for a review.

- [x] Ensure the branch is named correctly with the issue number. e.g: `feature/new-vpc-endpoints-955` or `bug/missing-count-param-434`.
- [x] Update the docs.
- [x] Keep the changes backward compatible where possible.
- [x] Run the pre-commit checks successfully.
- [x] Run the relevant tests successfully.

<br />
***


**yorinasub17** commented *Mar 11, 2022*

Thanks for review! Merging now.
***

