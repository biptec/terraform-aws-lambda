# Allow security group description value input

**onyicho-cr** commented *Apr 14, 2022*

<!--
Have any questions? Check out the contributing docs at https://gruntwork.notion.site/Gruntwork-Coding-Methodology-02fdcd6e4b004e818553684760bf691e,
or ask in this issue and a Gruntwork core maintainer will be happy to help :)
-->

**Describe the solution you'd like**
The solution we would like to see implemented would be an option to input a security group description value. Currently, the security group description is concatenating a hardcoded text. When importing an existing security group, if the description does not match then it forces a replacement. This is problematic when migrating existing lambda function into the module. 

**Describe alternatives you've considered**
Adding a security group description variable and possibly using the existing security group description value if the new input variable is null.

`description = var.security_group_description != null ? var.security_group_description : "Security group for the lambda function ${var.name}"`



**Additional context**
Deleting a security group on a VPC attached lambda is problematic because it requires detaching an ENI. 

<br />
***


**Etiene** commented *Apr 15, 2022*

Closed with #120 
***

