# Fix security group preventing lambda-vpc example from working. Update known issues

**zackproser** commented *Oct 6, 2021*

Bug fix: The lambda function's security group wasn't being passed into the allowed security groups for the EFS access points. This led to the example failing when you would issue a test against the deployed lambda. 

Doc update: The issue preventing a clean destroy of this example is now resolved, and therefore has been removed from the README. 
<br />
***


**zackproser** commented *Oct 19, 2021*

Thanks for the reviews! Going to merge this in now.
***

