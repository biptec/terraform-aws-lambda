# Add example using docker images

**Etiene** commented *Mar 1, 2022*

Create and test an example of creating a lambda function from a docker image in ECR 

### Additional context
* Make sure ECR permissions allow it
https://github.com/gruntwork-io/knowledge-base/discussions/225 
<br />
***


**fsanzdev** commented *Mar 2, 2022*

To have this working in the Ref Arch, we need to do 3 things:

- Modify the private registry policy in the shared account to allow access from the other accounts
- Modify the private registry policy in each account to allow access from the shared account
- Setup cross-account/cross-region replication in the shared private registry

Things missing in Ref Arch to do that (as far as I can tell):

- There is no way to modify the private registry policies from ecr-repo module
- The replication is only setup to allow cross-region (not cross-account)

***

**Etiene** commented *Mar 3, 2022*

Thank you for adding more context! This is really helpful
***

