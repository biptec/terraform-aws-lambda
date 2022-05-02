# Test fixes

**brikis98** commented *May 27, 2018*

I'm getting a lot of intermittent failures lately with Lambda.

* One is from a Terraform bug: https://github.com/terraform-providers/terraform-provider-aws/issues/4633. I have a retry in place to work around this.

* Another is from what seems to be due to IAM permissions taking a while to propagate:

    ```
    "AccessDeniedException: The role defined for the function cannot be assumed by Lambda."
    ```
    I've added retries to `triggerLambdaFunction` to work around this. 

* The keep-warm tests both failed on the last commit, but not the one before it. The cause, bizarrely, seems to be that the `keep-warm` function doesn't have `lambda:InvokeFunction` permissions to call the example functions... Even though it adds those *exact* permissions... And waits 1 minute before executing, which should be enough time for those permissions to propagate. Still trying to sort this one out.
<br />
***


**brikis98** commented *May 27, 2018*

OK, I've changed how the tests work to be a bit more robust. It's still not perfect, and there are occasional intermittent failures that seem to be further AWS or Terraform or eventual consistency bugs, but hopefully this is good enough for now. There are no real functionality changes, but minor cosmetic ones to `keep-warm`, so I'll re-release it with this PR.
***

