# Add depends-on workaround

**brikis98** commented *Sep 23, 2018*

This is an ugly workaround for the fact that Terraform doesn't support `depends_on` for modules. It forces all the resources in the `package-lambda` module to wait for a variable provided by the user. 
<br />
***


