# Resource: use aws_s3_object over aws_s3_bucket_object

**rhoboat** commented *Apr 28, 2022*

Addresses gruntwork-io/cloud-chasers#21, which is part of the AWS provider v4 update.
<br />
***


**gcagle3** commented *Apr 29, 2022*

Looks like the tests are failing: 

```
│ Error: Invalid resource type
│ 
│   on main.tf line 58, in resource "aws_s3_object" "deployment_package":
│   58: resource "aws_s3_object" "deployment_package" {
│ 
│ The provider hashicorp/aws does not support resource type "aws_s3_object".
╵}
```

Doing a quick check, I believe the test ran using the `hashicorp/aws v3.75.1` provider. The `aws_s3_object` resource wasn't added until provider version `hashicorp/aws v4.0.0`. Could we update the provider version for the examples? They should work once this change has been made. 
***

