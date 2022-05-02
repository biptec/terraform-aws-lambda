# Add support to disable source code updates beyond initial creation. A…

**jhughes-mc** commented *Mar 16, 2021*

We're currently using external tools to manage code deployments, in order to aid in our transition to Gruntwork, we wanted to create and manage all of the configuration for a lambda using Terraform, but still maintain the ability to deploy lamdba function code updates using our existing process.

The changes proposed allow an individual to set source_code_update = false, which will disable source_code_hash checking, and in turn, prevent terraform from updating the lambda function code once the terraform module has been executed, or imported into the state.
<br />
***


**Etiene** commented *Feb 24, 2022*

Hello @jhughes-mc, thanks again for the PR! I'm wondering if it's still possible to continue it? Otherwise I will close it as stale, thanks.
***

**jeffreymlewis** commented *Feb 24, 2022*

Hello @Etiene . I spoke with Jordan and decided to take over this PR. I've rebased and simplified the implementation a bit. Will test shortly. Let me know what you think.
***

**jeffreymlewis** commented *Feb 24, 2022*

@Etiene Testing is complete. I think this PR is ready for review!
***

**gcagle3** commented *Feb 24, 2022*

Thanks for all the hard work @jeffreymlewis! We're running the build tests and reviewing now. 
***

