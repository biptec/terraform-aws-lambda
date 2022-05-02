# Fix perpetual diff

**yorinasub17** commented *Dec 6, 2018*

This fixes the perpetual diff issue we were seeing by removing the `wait_for` null_resource which was not working properly.

Also:

- Upgrades `terratest`
- Installs `terratest_log_parser` to the circleci config.
<br />
***


**yorinasub17** commented *Dec 6, 2018*

Merging
***

