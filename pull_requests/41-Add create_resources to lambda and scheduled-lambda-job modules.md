# Add create_resources to lambda and scheduled-lambda-job modules

**yorinasub17** commented *Mar 12, 2020*

This adds the `create_resources` pattern to the `lambda` and `scheduled-lambda-job` modules in preparation for use with the service catalog.

Additional Improvements:

- Upgrade Terratest and `module-ci` to latest and use go modules
- Use test stages in lambda build test

Needs investigation

- [x] Do we need any state mv to go from non-count resource to count resource? => **Verified that a straight version bump to update to this version leads to plan with no changes**
<br />
***


**yorinasub17** commented *Mar 12, 2020*

Thanks for review! Merging this in now.
***

