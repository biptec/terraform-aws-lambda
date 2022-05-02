# Fix source_code_hash param for zip

**brikis98** commented *Jul 18, 2017*

This is follow-up to #4. The code I originally proposed for that PR had an issue: Terraform conditionals are not evaluated lazily. That is, the “if” and “else” branches of a conditional are *both* evaluated, regardless of whether the condition evaluates to true or false. This causes an issue with the call to `base64sha256(file(var.source_dir))` in the if-block, as `var.source_dir` may point to a folder rather than a file.

To fix this issue, I’m introducing a `template_file` data source and setting its `count` parameter to the same condition. If `count` is 0, then I *believe* the `template` body won’t be processed at all.
<br />
***


**brikis98** commented *Jul 18, 2017*

Tests passed, so I think this fixes the issue. Merging now. Feedback welcome!
***

**brikis98** commented *Jul 18, 2017*

@mtb-xt Give https://github.com/gruntwork-io/package-lambda/releases/tag/v0.0.4 a try.
***

**mtb-xt** commented *Jul 20, 2017*

thanks, seems to be working!
***

**mtb-xt** commented *Jul 20, 2017*

@brikis98  on a note - maybe with this change the 'source_dir' var should be renamed to 'source_path', to better reflect that it can be both a dir or a file?
***

**brikis98** commented *Jul 20, 2017*

@mtb-xt https://github.com/gruntwork-io/package-lambda/pull/6
***

