# Fix perpetual changes shown in plan when using image_uri

**gcagle3** commented *Apr 27, 2022*

<!--
Have any questions? Check out the contributing docs at https://gruntwork.notion.site/Gruntwork-Coding-Methodology-02fdcd6e4b004e818553684760bf691e,
or ask in this Pull Request and a Gruntwork core maintainer will be happy to help :)
Note: Remember to add '[WIP]' to the beginning of the title if this PR is still a work-in-progress. Remove it when it is ready for review!
-->

## Description

This PR adjusts the dynamic block "image_config" logic to require `var.entry_point`, `var.command`, or `var.working_directory` be set before it will make changes. This will prevent an issue where perpetual empty changes will be recommended when running the terraform plan. 
 
## TODOs

Please ensure all of these TODOs are completed before asking for a review.

- [x] Ensure the branch is named correctly with the issue number. e.g: `feature/new-vpc-endpoints-955` or `bug/missing-count-param-434`.
- [x] Update the docs.
- [x] Keep the changes backward compatible where possible.
- [x] Run the pre-commit checks successfully.
- [x] Run the relevant tests successfully.
- [x] Ensure any 3rd party code adheres with our [license policy](https://www.notion.so/gruntwork/Gruntwork-licenses-and-open-source-usage-policy-f7dece1f780341c7b69c1763f22b1378) or delete this line if its not applicable.


## Related Issues

Addresses #90 
<!--
  Link to related issues, and issues fixed or partially addressed by this PR.
  e.g. Fixes #1234
  e.g. Addresses #1234
  e.g. Related to #1234
-->

<br />
***


**gcagle3** commented *Apr 28, 2022*

> I have one question though, but it is not related to your PR since it seems it was already like this before. Do you know why this code uses `for_each` instead of `count`? I dont think I understand

I _think_ [for_each](https://www.terraform.io/language/meta-arguments/for_each) was chosen here because it is more flexible than [count](https://www.terraform.io/language/meta-arguments/count). While both `count` and `for_each` allow you to create multiple instances of a resource by iterating over a list, I believe the main difference is that `count` is sensitive to the order of the items (meaning that if you add an item, it will want to destroy and recreate _all_ items). The functionality of `for_each` is a lot more flexible in this sense because it takes a map/set as input and uses the key of a map index for the resources it creates.

It looks like the official Terraform recommendation is as follows: 

`If your instances are almost identical, count is appropriate. If some of their arguments need distinct values that can't be directly derived from an integer, it's safer to use for_each.`
***

**Etiene** commented *Apr 29, 2022*

~~@gcagle3 I think I'm still missing something? Isn't there only one or zero `image_config` being created instead of multiple:~~

```
? ["once"] : []
```

EDIT: oooooops, nevermind! it seems `dynamic` blocks just don't have `count`: https://www.terraform.io/language/expressions/dynamic-blocks

***

**gcagle3** commented *Apr 29, 2022*


> EDIT: oooooops, nevermind! it seems `dynamic` blocks just don't have `count`: https://www.terraform.io/language/expressions/dynamic-blocks

@Etiene Oh cool, thanks for sharing this! I learned something new!
***

