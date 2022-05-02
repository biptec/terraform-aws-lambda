# Add keep-warm module

**brikis98** commented *May 26, 2018*

This PR adds a `keep-warm` module that can be used to invoke Lambda functions on a scheduled basis to prevent them from having a cold start. The `keep-warm` module allows you to specify how often to trigger the functions, the concurrency level (to keep multiple containers warm for each function), and the event object to pass to the functions when invoking them.

This PR also updates to the latest version of Terratest and adds an `owners.txt`.
<br />
***


**brikis98** commented *May 26, 2018*

@mcalhoun I think we can use this with the Lambda/API Gateway/Express endpoint by setting the event object to a very simplified version of [this](https://serverless.com/framework/docs/providers/aws/events/apigateway/#example-lambda-proxy-event-default). The following will probably be enough:

```json
{
    "resource": "/",
    "path": "/",
    "httpMethod": "GET",
    "headers": {
        "Accept": "text/html",
        "User-Agent": "keep-warm"
    }
}
```
***

**brikis98** commented *May 27, 2018*

Man, getting good tests around this was not easy. Still not 100% sure this will work well, but they are passing now. Merging. Feedback very welcome.
***

