# Fix another cause of perpetual diff

**yorinasub17** commented *Dec 9, 2018*

I noticed the `lambda.zip` file is exported into the `source_dir`. This causes subsequent runs to zip up the previous runs `lambda.zip` file. It appears that normally this doesn't cause a perpetual diff (e.g in this modules' examples), but for some reason in `module-data-storage`, the `lambda.zip` file gets an updated modified timestamp every time, causing the created zip file's hash to change. Either way, it probably doesn't make sense to have a previous run's zip file end up in the lambda zip.

As far as the solution goes, since I didn't want to break backwards compatibility, I decided to take in another variable `zip_output_dir` that dictates where the zipfile should end up. If unset, it goes back to the old behavior. I originally had it generating in the module path, but then the tests in this package started breaking because each zip overwrote the others when run concurrently (since the tf module is initializing to the local path), and it felt like too much change to rename the zip. If you feel that is a better solution though (to use "${path.module}/lambda_${var.name}.zip`), I am happy to change it to that.
<br />
***


**brikis98** commented *Dec 10, 2018*

Oh, good catch. It seems that outputting the zip back into the source_path is almost always going to cause issues on re-runs, so I'd be in favor of a backwards incompatible fix here where the output path is configurable (so you can always reset it to whatever you need) but the default is something safer (e.g., using `path.module` or a temp dir).
***

**yorinasub17** commented *Dec 10, 2018*

@brikis98 Ok I changed it to:

- Take in the zip path as a full path as opposed to dir so that you can set the file name as well
- Update default to store in the module path, but prefixed with lambda name.
***

**yorinasub17** commented *Dec 10, 2018*

Ok accepted proposed changes and updated the description. Going to go ahead and merge + release this, and then update module-data-storage.
***

