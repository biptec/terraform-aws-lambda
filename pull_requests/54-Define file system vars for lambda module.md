# Define file system vars for lambda module

**evanfuller** commented *Oct 30, 2020*

Add support for the EFS mount file_system block on the lambda module. Note that in order to add a FS mount, the lambda must be deployed on a VPC.
<br />
***


**evanfuller** commented *Oct 30, 2020*

i've added an example @brikis98 @yorinasub17; let me know if you need anything else from me to move this along.
***

**brikis98** commented *Nov 3, 2020*

Tests failed due to a precommit / Python EOL issue in our build. Working on a fix here: https://github.com/gruntwork-io/package-lambda/pull/55.
***

**brikis98** commented *Nov 3, 2020*

OK, https://github.com/gruntwork-io/package-lambda/pull/55 is now merged. Could you pull in the latest from `master`, and I'll kick off the tests again?
***

**evanfuller** commented *Nov 4, 2020*

@brikis98 done!
***

**brikis98** commented *Nov 5, 2020*

Kicking off tests again!
***

**brikis98** commented *Nov 5, 2020*

https://github.com/gruntwork-io/package-lambda/releases/tag/v0.9.3
***

**evanfuller** commented *Nov 5, 2020*

@brikis98 thanks so much!
***

