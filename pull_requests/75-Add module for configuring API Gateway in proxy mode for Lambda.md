# Add module for configuring API Gateway in proxy mode for Lambda

**yorinasub17** commented *Jul 13, 2021*

This adds a new module for configuring an API Gateway Domain that can proxy requests to a lambda function that knows how to handle those requests.

See the module docs + examples for more information.
<br />
***


**yorinasub17** commented *Jul 15, 2021*

Ok this has gone quite a reshaping in the latest iteration, so it warrants another full look. Here is the summary of changes:

- The proxy methods are now creating in a new module `api-gateway-proxy-methods`. This allows users to bind other lambda functions to the same API gateway under different path prefixes, both in the `api-gateway-proxy` module and outside. e16c434
- Relevant outputs for attaching additional methods are now provided.
- You can now configure a domain.
- Tests have been enhanced to test both the case where there is no custom domain attached and when there is a custom domain attached.

Note that the domain attachment feature required usage of `configuration_aliases` due to the annoying fact that it requires an ACM cert in `us-east-1` when configuring a domain for an API Gateway exposed to the world.
***

**yorinasub17** commented *Jul 20, 2021*

@brikis98 I believe I addressed all your concerns! This is ready for another round of review.
***

**yorinasub17** commented *Jul 22, 2021*

Thanks for review! Going to release this now.
***

