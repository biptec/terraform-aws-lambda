# dependence on archive_file provider breaks most use-cases

**ghost** commented *Nov 19, 2018*

The archive_file provider does not support symlinks anywhere within the source_dir, which is kind of ridiculous, since the bug has been known for 18 months and it all but eliminates the utility of the archive_file provider - especially if someone is using node for their lambda and has any kind of monorepo with local packages hoisted to the top-level, and symlinks back to the local package directory. It becomes impossible to use the lambda module without archiving your own source code into a zip, first, but that then eliminates much of the utility of this module.  Zipping up a directory is an almost trivial operation that should either be handled by an external script, as suggested by a comment in the issue filed against the archive provider (https://github.com/terraform-providers/terraform-provider-archive/issues/6 ), or done in some other manner, so that every single user of the module doesn't end up re-implementing the archiving functionality in order to pass through a zip file path instead of creating the zip file within the module.
<br />
***


**ghost** commented *Nov 20, 2018*

To replicate what your use of the archive_file provider is currently doing, use a script that does this:

```
#!/bin/sh

set -e

# Extract "src_dir" argument from the input into # STEM_SRC_DIR shell variable.
# jq will ensure that the value is properly quoted and escaped for consumption
# by the shell.
eval "$(jq -r '@sh "STEM_SRC_DIR=\(.src_dir)"')"

pushd $STEM_SRC_DIR &>/dev/null
zip -r -X lambda.zip * &>/dev/null
zip_file="$STEM_SRC_DIR/lambda.zip"
zip_hash="$(cat "$STEM_SRC_DIR/lambda.zip" | shasum -a 256 | cut -d " " -f 1 | xxd -r -p | base64)"
zip_md5="$(cat "$STEM_SRC_DIR/lambda.zip" | md5)"
popd &>/dev/null

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg zip_file "$STEM_SRC_DIR/lambda.zip" --arg hash "$zip_hash" --arg md5 "$zip_md5" '{"zip_file":$zip_file, "hash":$hash, "md5":$md5}'
```

And call it from a module or template like this:

```
data "external" "zip_source" {
  program = [ "scripts/zip_source.sh" ]

  query = {
    src_dir = "${var.top_level_dir_path}/${var.path_to_lambda_src_dir}"
  }
}
```

And then you can access the zip file path and checksums directly via this:

```
source_path = "${data.external.zip_source.result["zip_file"]}"
hash = "${data.external.zip_source.result["hash"]}"
md5 = "${data.external.zip_source.result["md5"]}"
```


***

**ghost** commented *Nov 20, 2018*

I'm working from a fork of your module, so I have no easy way to generate a PR without other diffs, so you'll have to make a PR with the script and the modified calling syntax.
***

**brikis98** commented *Nov 20, 2018*

Hm, that's a frustrating bug in `archive_file`. Unfortunately, using a bash script to work around it is not a viable solution, as we have customers that run Terraform from Windows. We may be able to get away with a Python script (albeit, one carefully written to be agnostic to Python 2 vs 3), and we'll need that script to handle file paths and symlinks across multiple operating systems...
***

