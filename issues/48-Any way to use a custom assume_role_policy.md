# Any way to use a custom `assume_role_policy`?

**RichardBronosky** commented *Jun 23, 2020*

I want my CI/CD process to be able to assume the role to run tests. Tests that fail for the role of the lambda pass for the `allow-auto-deploy-from-other-accounts` role.
<br />
***


**brikis98** commented *Jun 24, 2020*

Sorry, I'm not sure I follow... Could you provide a bit more context? What module(s) are you using? What are you using them for? How are you testing?
***

**jessiehernandez** commented *Nov 19, 2020*

I have a similar need. In order to create a password rotator Lambda, I need to grant Secrets Manager the following permission in the Trust Policy, as described in https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotating-secrets-required-permissions.html :

```
{
  "Version": "2012-10-17",
  "Id": "default",
  "Statement": [
    {
      "Sid": "EXAMPLE1-90ab-cdef-fedc-ba987EXAMPLE",
      "Effect": "Allow",
      "Principal": {
        "Service": "secretsmanager.amazonaws.com"
      },
      "Action": "lambda:InvokeFunction",
      "Resource": "<arn of the Lambda function that this trust policy is attached to - must match exactly>"
    }
  ]
}
```

***

**brikis98** commented *Nov 19, 2020*

https://github.com/gruntwork-io/package-lambda/pull/56
***

