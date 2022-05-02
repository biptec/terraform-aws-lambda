# Optionally create an outbound rule

**bwhaley** commented *Oct 6, 2020*

Allows users to optionally create a rule in the Lambda function's security group allowing all outbound traffic from the Lambda to `0.0.0.0/0`. This will permit the function to access network resources, such as AWS APIs, databases, etc, and will likely prevent confusion for users who are trying out the module for the first time.
<br />
***


**bwhaley** commented *Oct 15, 2020*

Thanks! Merging this in.
***

