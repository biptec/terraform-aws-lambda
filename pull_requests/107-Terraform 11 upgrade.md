# Terraform 1.1 upgrade

**infraredgirl** commented *Feb 14, 2022*

Part of https://github.com/gruntwork-io/patcher/issues/118.
<br />
***


**gcagle3** commented *Feb 14, 2022*

The tests failed, but it looks like there were a few network errors that caused this: 

```
TestLambdaService/RegionalWithDomain 2022-02-14T15:45:59Z save_test_data.go:199: 
...
Failed to retrieve plugin due to transient network error.",".*registry service is unreachable.*"
```

Would it be possible to kick off the tests a second time?
***

**infraredgirl** commented *Feb 16, 2022*

Thanks for the reviews! Going to merge and release.
***

