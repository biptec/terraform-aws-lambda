# Error when local zip file doesn't exist and s3 options are utilized

**ghost** commented *Jun 5, 2018*

If using the s3-based zip file option, the module still attempted to compute the checksum of a non-existent local file.  I assume the test code, which seems to address this scenario, does have a copy of the zip file locally because it has to upload it, so the test isn't failing.  
<br />
***


