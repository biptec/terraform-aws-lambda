# v0.0.1 of package-lambda

**brikis98** commented *May 31, 2017*

This PR creates a new Infrastructure Package for deploying and managing lambda functions. This first version has just two modules:

1. `lambda`: deploy a single lambda function.
1. `scheduled-lambda-job`: configure a lambda function to run on a scheduled basis. This part used to be in `module-ci`, so we’ll have to deprecate the original module and tell users to migrate to this new one.

Examples, docs, and tests are included. In the future, we’ll hopefully be able to add API Gateway integration in this Package.
<br />
***


**brikis98** commented *Jun 1, 2017*

I'm going to merge now so @anaulin can start trying this out and provide feedback. @josh-padnick Review when you can and I'll incorporate your suggestions in a follow-up PR.
***

**brikis98** commented *Jun 1, 2017*

OK, new release created: https://github.com/gruntwork-io/package-lambda/releases/tag/v0.0.1. @anaulin Try it out and let me know how it goes!
***

**anaulin** commented *Jun 2, 2017*

![](https://media0.giphy.com/media/TXJiSN8vCERuE/200w.gif)

(Will let y'all know how it goes.)
***

**brikis98** commented *Jun 6, 2017*

BTW, @anaulin, please let me know how your experimentation goes. I'm very curious to hear if the lambda approach works out for your app. Also, I'll hold off on sending the final invoice for this project for a little longer in case you hit bugs or other issues. Thanks!
***

**anaulin** commented *Jun 8, 2017*

@brikis98 i am struggling to make this work. I am building off of your `lambda-s3` example, with a base module that sources this `package-lambda`, and then a concrete module that sources my base module. Currently, I get the following error when I try to do a `get`:
```bash
$ terragrunt get -update
[terragrunt] 2017/06/08 13:35:00 Running command: terraform get -update
Get: file:///Users/aulin/src/github.com/dfxmachina/infrastructure-modules/image-lambda (update)
Get: git::ssh://git@github.com/gruntwork-io/package-lambda.git?ref=v0.0.1 (update)
Error loading Terraform: Error downloading modules: module image_lambda: Error loading .terraform/modules/1a36e2e8317b2394def0c5be8aae815d/modules/lambda/main.tf: Error reading config for archive_file[source_code]: parse error: syntax error
[terragrunt] 2017/06/08 13:35:02 exit status 1
```

I believe this error is pointing at something in the gruntwork package not being parseable. In my module, I have `source_dir = "${path.module}/source_dir"` (changing it to other things doesn't seem to help). I do not have a custom `zip_dir` set.
***

**anaulin** commented *Jun 8, 2017*

Some research suggests that Terraform error messages are terrible and might not be actually point at the true root cause of the issue. So I guess this just means that my WIP has a syntax error somewhere, likely not in the base module, which is presumably tested and thus solid. :woman_shrugging: 
***

**anaulin** commented *Jun 8, 2017*

Just a `main.tf` that sources this package fails to load with a syntax error:
```bash
~/src/github.com/dfxmachina/infrastructure-live/stage/image-lambda (image-lambda) $ ls -lh
total 8
-rw-r--r--  1 aulin  staff   417B Jun  8 14:14 main.tf
~/src/github.com/dfxmachina/infrastructure-live/stage/image-lambda (image-lambda) $ cat main.tf 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY THE IMAGE LAMBDA IN THE STAGE ENVIRONMENT
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

module "image-lambda-stage" {
  source = "git::git@github.com:gruntwork-io/package-lambda.git//modules/lambda?ref=v0.0.1"
}
~/src/github.com/dfxmachina/infrastructure-live/stage/image-lambda (image-lambda) $ terragrunt get -update
[terragrunt] 2017/06/08 14:15:02 Running command: terraform get -update
2017/06/08 14:15:02 [INFO] Terraform version: 0.7.13  2a4b4bbc3f315d100f76a83570e0364275e0fc6b
2017/06/08 14:15:02 [INFO] CLI args: []string{"/Users/aulin/src/github.com/dfxmachina/scripts/terraform_0.7.13", "get", "-update"}
2017/06/08 14:15:02 [DEBUG] Detected home directory from env var: /Users/aulin
2017/06/08 14:15:02 [DEBUG] Detected home directory from env var: /Users/aulin
2017/06/08 14:15:02 [DEBUG] Attempting to open CLI config file: /Users/aulin/.terraformrc
2017/06/08 14:15:02 [DEBUG] File doesn't exist, but doesn't need to. Ignoring.
2017/06/08 14:15:02 [DEBUG] Detected home directory from env var: /Users/aulin
Get: git::ssh://git@github.com/gruntwork-io/package-lambda.git?ref=v0.0.1 (update)
2017/06/08 14:15:06 [DEBUG] plugin: waiting for all plugin processes to complete...
Error loading Terraform: Error downloading modules: module image-lambda-stage: Error loading .terraform/modules/6426d12c8d3401629a2ff2d22f5e05df/modules/lambda/main.tf: Error reading config for archive_file[source_code]: parse error: syntax error
[terragrunt] 2017/06/08 14:15:06 exit status 1

```
***

**brikis98** commented *Jun 8, 2017*

Out of curiosity, are you able to `git clone` the repo? 
***

**anaulin** commented *Jun 8, 2017*

Yes, I am (otherwise how would it even know to refer to a line that is only in the base package, like the archive resource):
```bash
$ git clone git@github.com:gruntwork-io/package-lambda.git
Cloning into 'package-lambda'...
remote: Counting objects: 184, done.
remote: Compressing objects: 100% (123/123), done.
remote: Total 184 (delta 77), reused 152 (delta 46), pack-reused 0
Receiving objects: 100% (184/184), 130.27 KiB | 0 bytes/s, done.
Resolving deltas: 100% (77/77), done.
Checking connectivity... done.
$ ls -l package-lambda/
total 24
-rw-r--r--   1 aulin  staff   385 Jun  8 14:24 LICENSE.txt
-rw-r--r--   1 aulin  staff  3730 Jun  8 14:24 README.md
-rw-r--r--   1 aulin  staff   903 Jun  8 14:24 circle.yml
drwxr-xr-x   6 aulin  staff   204 Jun  8 14:24 examples
drwxr-xr-x   4 aulin  staff   136 Jun  8 14:24 modules
drwxr-xr-x  11 aulin  staff   374 Jun  8 14:24 test
```
***

**anaulin** commented *Jun 8, 2017*

Furthermore, just trying to `terragrunt get` the `lambda-s3` example fails with the same message:
```bash
~/src/github.com/gruntwork-io/package-lambda/examples/lambda-s3 (master) $ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Untracked files:
  (use "git add <file>..." to include in what will be committed)

	.terragrunt

nothing added to commit but untracked files present (use "git add" to track)

~/src/github.com/gruntwork-io/package-lambda/examples/lambda-s3 (master) $ cat .terragrunt 
# This file configures Terragrunt, which is a thin wrapper for Terraform that supports locking and enforces best
# practices: https://github.com/gruntwork-io/terragrunt

# Configure Terragrunt to use DynamoDB for locking
dynamoDbLock = {
  stateFileId = "lambda-s3-test"
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket
remoteState = {
  backend = "s3"
  backendConfigs = {
    encrypt = "true"
    bucket = "instrumental-terraform-state"
    key = "stage/lambda-s3-test/terraform.tfstate"
    region = "us-west-2"
  }
}

~/src/github.com/gruntwork-io/package-lambda/examples/lambda-s3 (master) $ terragrunt get -update
[terragrunt] 2017/06/08 14:29:21 Running command: terraform get -update
Get: file:///Users/aulin/src/github.com/gruntwork-io/package-lambda/modules/lambda (update)
Error loading Terraform: Error downloading modules: module lambda_s3: Error loading .terraform/modules/dfde8d84dcb3b864536dcc07832cc681/main.tf: Error reading config for archive_file[source_code]: parse error: syntax error
[terragrunt] 2017/06/08 14:29:21 exit status 1
```
***

**brikis98** commented *Jun 8, 2017*

It's possible that your old version of Terraform is obscuring the real error message. Here's what I tried with a recent version of Terraform:

```hcl
module "image-lambda-stage" {
  source = "git::git@github.com:gruntwork-io/package-lambda.git//modules/lambda?ref=v0.0.1"
}
```

When I run `terraform get`:

```hcl
brikis98-pro:lambda-test brikis98$ terraform get
Get: git::ssh://git@github.com/gruntwork-io/package-lambda.git?ref=v0.0.1
Error loading Terraform: module root: module image-lambda-stage: required variable source_dir not set
```

So I filled in the required params:

```hcl
module "image-lambda-stage" {
  source = "git::git@github.com:gruntwork-io/package-lambda.git//modules/lambda?ref=v0.0.1"

  name = "foo"
  source_dir = "src"

  runtime = "python2.7"
  handler = "index.handler"

  timeout = 30
  memory_size = 128
}
```

And re-run `get`:

```
brikis98-pro:lambda-test brikis98$ terraform get
Get: git::ssh://git@github.com/gruntwork-io/package-lambda.git?ref=v0.0.1
```
***

**brikis98** commented *Jun 8, 2017*

The examples work just fine on my computer and in our CI environment... Try downloading a newer version of the Terraform binary to see if it makes a difference?
***

**anaulin** commented *Jun 8, 2017*

Indeed, I downloaded v0.9.8 and that worked. I'll work on upgrading us to that version, and hope it doesn't break something else.

Thanks for your help, @brikis98 
***

**brikis98** commented *Jun 8, 2017*

@anaulin That's potentially a pretty big update! A lot has changed from Terraform 0.7.x to 0.9.x, especially 0.9.x, which changes how remote state works in a backwards incompatible way. You'd have to upgrade Terragrunt, potentially some Gruntwork modules as well, and make code changes. Getting on the latest and greatest is definitely a good thing to do, and potentially something we could help with in a future month (as part of support), but it's not a quick undertaking, and probably not something you'll want to do piecemeal (i.e. have half your modules on terraform 0.7.x and half on 0.9.x).

Perhaps try to update to Terraform 0.8 first and see how that works for you? That's a smaller jump and from a quick test, 0.8 works fine with this lambda code.
***

**anaulin** commented *Jun 8, 2017*

I just tried with 0.8.4 and that also seems to work. I suppose I can upgrade us to that, but now I'm worried as to what else is this going to break.
***

**brikis98** commented *Jun 8, 2017*

Ah, I have a guess as to what is causing this, though the error message is quite terrible :)

I'm using a conditional in the [lambda module](https://github.com/gruntwork-io/package-lambda/blob/master/modules/lambda/main.tf#L84). Conditionals were only added in [Terraform 0.8](https://www.hashicorp.com/blog/terraform-0-8/#conditional-values). I'm using it for a feature that isn't strictly necessary, so I can probably remove it if that will make your life easier.
***

**brikis98** commented *Jun 8, 2017*

@anaulin Try an experiment: use Terraform 0.7.x, but instead of `ref=v0.0.1`, set `ref=remove-conditional`, and let me know if `terraform get` works.
***

**brikis98** commented *Jun 8, 2017*

See also https://github.com/gruntwork-io/package-lambda/pull/2
***

**anaulin** commented *Jun 8, 2017*

>@anaulin Try an experiment: use Terraform 0.7.x, but instead of ref=v0.0.1, set ref=remove-conditional, and let me know if terraform get works.

That does work with Terraform 0.7.13. Thanks for the fix!
***

**brikis98** commented *Jun 8, 2017*

@anaulin OK, give [v0.0.2](https://github.com/gruntwork-io/package-lambda/releases/tag/v0.0.2) a try then.
***

**anaulin** commented *Jun 8, 2017*

v0.0.2 does seem work ✅ 
***

**brikis98** commented *Jun 8, 2017*

Good! Keep me posted on how things work out.
***

**anaulin** commented *Jun 8, 2017*

New question: I thought that if I didn't set `kms_key_arn` to anything it would use a default, but it looks like that's not the case:
```
aws_lambda_function.function_not_in_vpc: "kms_key_arn" doesn't look like a valid ARN ("^arn:aws:([a-zA-Z0-9\\-])+:([a-z]{2}-[a-z]+-\\d{1})?:(\\d{12})?:(.*)$"): ""
```

I can use our staging key arn for now, but wondering if this was the intended behavior.
***

**anaulin** commented *Jun 8, 2017*

Actually, I'd rather not have to provide a kms arn here if I don't have to. It seems when I create a Lambda via the AWS console it has a default kms key for the Lambda that it uses. Can we do the same here?
***

**brikis98** commented *Jun 8, 2017*

I'm not specifying a KMS key in any of the examples and IIRC, it picks up the default key: https://github.com/gruntwork-io/package-lambda/blob/master/examples/lambda-s3/main.tf#L18-L30. 

Could this be another thing that changed with a more recent version of Terraform?
***

**anaulin** commented *Jun 8, 2017*

Indeed, I don't get this problem with Terraform v0.8.8. 😿 
***

**brikis98** commented *Jun 8, 2017*

:(

Not sure I can offer any workaround for that other than passing your own KMS key from stage/prod.
***

**anaulin** commented *Jun 8, 2017*

I guess we need to upgrade to v0.8.8.
***

**brikis98** commented *Jun 8, 2017*

Roger.
***

