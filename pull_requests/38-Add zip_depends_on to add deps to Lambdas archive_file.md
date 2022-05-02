# Add `zip_depends_on` to add deps to Lambda's `archive_file`

**domcleal** commented *Jan 30, 2020*

This makes it possible to build a Lambda zip file with a temporary build
directory or other file resources by passing the resource references in
and building the zip once they're ready. Without it, the zip will build
from the source directory as soon as possible.
<br />
***


**domcleal** commented *Feb 4, 2020*

Thanks for reviewing this @yorinasub17, but I think I'm going to retract this as it reintroduces the same problem that you fixed in #27. If people put other build/prep resources as dependencies to the `archive_file` data resource then it'll just cause perpetual diffs/changes to show up.

There isn't a good solution to this in Terraform and we probably shouldn't be encouraging people to build and deploy in one step in Terraform by adding this input.
***

**yorinasub17** commented *Feb 4, 2020*

> If people put other build/prep resources as dependencies to the archive_file data resource then it'll just cause perpetual diffs/changes to show up.

Ah gotcha. There is probably a better way to handle this, but you might be right here. Thanks for closing the loop!
***

