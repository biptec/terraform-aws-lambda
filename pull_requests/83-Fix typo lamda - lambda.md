# Fix typo: lamda -> lambda

**zackproser** commented *Oct 6, 2021*

These changes fix a typo in the `aws_iam_role_policy`, changing its name from "network_interfaces_for_lamda" to "network_interfaces_for_lam**b**da".
<br />
***


**zackproser** commented *Oct 14, 2021*

This release fixes a typo in the  `aws_iam_role_policy` resource, changing the name from "network_interfaces_for_lamda" to "network_interfaces_for_lam**b**da". This is a backward incompatible change, requiring re-creation of the `aws_iam_role_policy`. 

However, the downtime incurred by this operation should be so brief as to be negligible, because the policy will be removed and immediately added back at apply time. 

However, if you wish to avoid this brief downtime, you can use the `terraform state mv` operation to move your `aws_iam_role_policy` resource's state via the following command: 

`terraform state mv aws_iam_role_policy.network_interfaces_for_lamda aws_iam_role_policy.network_interfaces_for_lambda`

@yorinasub17 when you have a moment please have a look ^
***

**zackproser** commented *Oct 16, 2021*

Thanks for the reviews! Going to merge this in now. 
***

