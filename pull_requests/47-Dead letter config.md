# Dead letter config

**kevingunn-wk** commented *May 21, 2020*

Adding `dead_letter_config` back into the lambda and lambda-edge modules now that https://github.com/hashicorp/terraform/issues/14961 is closed.

This is an updated PR for the now stale #19 

Was tested by adding the change and deploying to an existing lambda. Verified the DLQ was configured and the receiving SNS topic received the event.
<br />
***


**zackproser** commented *May 21, 2020*

Thanks for contributing this @kevingunn-wk! It's now in our queue to review. 

One thing we're going to want to do before this gets merged is ensure we have a test verifying that this works. It sounds like we may have already written one at some point, so I'm going to look for it now. 

In the meantime, just wanted you to know we're going to take a look at this and appreciate your contribution!
***

**zackproser** commented *May 22, 2020*

Hi @kevingunn-wk - unfortunately I wasn't able to find one - would you be up for adding a test via [Terratest](https://github.com/gruntwork-io/terratest) following the patterns in our current tests? If not - no problem - we will add it to our queue and handle it ourselves but this will likely take longer. Thanks!
***

**kevingunn-wk** commented *May 23, 2020*

Sure, I'll take look and get started on a test.
***

**zackproser** commented *May 26, 2020*

> Sure, I'll take look and get started on a test.

Great, thank you!
***

**kevingunn-wk** commented *May 27, 2020*

Added an [example](examples/lambda-dead-letter-queue/README.md) and [test](test/lambda_dead_letter_queue_test.go) for dead_letter_config testing and while that test alone passes, the other tests fail with something similar to this message:

> Error: Nil dead_letter_config supplied for function: TestLambdaS3Reserved-VPflgL

Went back and read up on https://github.com/hashicorp/terraform/issues/14961 and realized that the bug originally reported was a panic issue in Terraform. That issue has been fixed and now Terraform will output an error message when the `target_arn` for `dead_letter_config` is an empty string. It also fails if the value is `null`.

I found this comment in a linked issue: https://github.com/hashicorp/terraform/pull/14964#issuecomment-305325414. Basically, there isn't an inherent way to disable `dead_letter_config` if the provided `target_arn` is an empty string.

 I'll try explore this a little more, but sounds like this may not work as intended.
***

**kevingunn-wk** commented *May 27, 2020*

Got tests to pass after setting up `dead_letter_config` as a dynamic block.

Test results:
> PASS
>ok  	github.com/gruntwork-io/package-lambda/test	382.610s
***

**zackproser** commented *May 28, 2020*

Awesome - thanks @kevingunn-wk - we will take a look!
***

**yorinasub17** commented *Jun 1, 2020*

Thanks for making the changes! This looks good now. Just kicked off a build and if it passes, we can merge this in!
***

**yorinasub17** commented *Jun 1, 2020*

The build passed, so will go ahead and merge this in. Thanks for your contribution!
***

**yorinasub17** commented *Jun 1, 2020*

Released as https://github.com/gruntwork-io/package-lambda/releases/tag/v0.8.1
***

