# Upgrade to terraform 0.12 syntax

**yorinasub17** commented *Jun 14, 2019*

This updates all the modules to be terraform 0.12 compatible. In practice, this means I ran `terraform 0.12upgrade` and then used the tests to flush out all the bugs.

This also updates all the default variables to use lambda runtime `nodejs8.10` instead of `nodejs6.10`
<br />
***


**yorinasub17** commented *Jun 14, 2019*

Ok going to merge and release this. If I have time, I will try the suggested optimization.
***

**yorinasub17** commented *Jun 14, 2019*

Thanks for the review!
***

