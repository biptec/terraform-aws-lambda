# Update repo to work with TF 0.13

**brikis98** commented *Sep 18, 2020*

1. Update CI build to TF 0.13
1. Pin all modules to `>= 0.12.26`
1. Add pre-commit hooks
1. Fix formatting issues uncovered by pre-commit hooks
<br />
***


**brikis98** commented *Sep 18, 2020*

Tests are passing. This is ready for review!
***

**brikis98** commented *Sep 18, 2020*

Thanks for the review! Going to punt on `goimports` for now. Could perhaps change to using it as the pre-commit hook in the future, but `go fmt` for now will be an improvement.
***

