# fix(lambda): adjusting lambda output value technique

**jdhornsby** commented *May 6, 2020*

We experience failures during destroy if a previous destroy attempt failed midway through due the explicit reference to resources indices. Switching to a string join approach fixes these issues for us.

This may cause issues because I believe this will emit empty strings instead of nulls. I can work with you to address this behavior if needed.
<br />
***


**yorinasub17** commented *May 7, 2020*

The build passed, so will go ahead and merge this. Thanks for your contribution!
***

