# add security_group_description input  

**onyicho-cr** commented *Apr 14, 2022*

<!--
Have any questions? Check out the contributing docs at https://gruntwork.notion.site/Gruntwork-Coding-Methodology-02fdcd6e4b004e818553684760bf691e,
or ask in this Pull Request and a Gruntwork core maintainer will be happy to help :)
Note: Remember to add '[WIP]' to the beginning of the title if this PR is still a work-in-progress. Remove it when it is ready for review!
-->

## Description

Describe the solution you'd like
The solution we would like to see implemented would be an option to input a security group description value. Currently, the security group description is concatenating a hardcoded text. When importing an existing security group, if the description does not match then it forces a replacement. This is problematic when migrating existing lambda function into the module.

Describe alternatives you've considered
Adding a security group description variable and possibly using the existing security group description value if the new input variable is null.

description = var.security_group_description != null ? var.security_group_description : "Security group for the lambda function ${var.name}"

Additional context
Deleting a security group on a VPC attached lambda is problematic because it requires detaching an ENI.
### Documentation

<!--
  If this is a feature PR, then where is it documented?

  - If docs exist:
    - Update any references, if relevant.
  - If no docs exist:
    - Create a stub for documentation including bullet points for how to use the feature, code snippets (including from happy path tests), etc.
-->

<!-- Important: Did you make any backward incompatible changes? If yes, then you must write a migration guide! -->

## TODOs

Please ensure all of these TODOs are completed before asking for a review.

- [X] Ensure the branch is named correctly with the issue number. e.g: `feature/new-vpc-endpoints-955` or `bug/missing-count-param-434`.
- [X] Update the docs. (no update needed)
- [X] Keep the changes backward compatible where possible.
- [X] Run the pre-commit checks successfully.
- [X] Run the relevant tests successfully.


## Related Issues

<!--
  Link to related issues, and issues fixed or partially addressed by this PR.
  e.g. Fixes #1234
  e.g. Addresses #1234
  e.g. Related to #1234
-->

https://github.com/gruntwork-io/terraform-aws-lambda/issues/119

<br />
***


**gcagle3** commented *Apr 14, 2022*

Thank you for the PR @onyicho-cr! Your proposed change makes sense and preserves existing functionality, so I'm going to go ahead and run the necessary tests and complete a review. 
***

**gcagle3** commented *Apr 14, 2022*

@onyicho-cr thank you again for the contribution! This change has been merged and is available in release [v0.18.4](https://github.com/gruntwork-io/terraform-aws-lambda/releases/tag/v0.18.4)!
***

**onyicho-cr** commented *Apr 14, 2022*

Awesome! Thank you for your quick reply!
***

