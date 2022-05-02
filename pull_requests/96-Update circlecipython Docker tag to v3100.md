# Update circleci/python Docker tag to v3.10.0

**gruntwork-patcher** commented *Dec 10, 2021*

[![Patcher](https://www.gruntwork.io/assets/img/logos-patcher/patcher-PR-banner.png)](https://gruntwork.io/)

This PR contains the following updates:

| Package | Update | Type | New value | Release Notes |
|---|---|---|---|---|
| circleci/python | Major **[BACKWARDS INCOMPATIBLE, SEE RELEASE NOTES]** | docker | 3.10.0 | [Release Notes]({depName}}/releases/tag/3.10.0) |

:warning: This is a **backwards incompatible upgrade**. You MUST follow the instructions in the [Release Notes](circleci/python/releases/tag/3.10.0) to upgrade! If you are upgrading across multiple backwards incompatible versions (e.g., `v0.3.0` to `v0.6.0`), you MUST check the release notes for every release in between too! :warning:

---

Please merge this manually once you are satisfied or close the PR and you won't be reminded about this update again.
<br />
***


**marinalimeira** commented *Dec 10, 2021*

Hey @yorinasub17! Should this python release be considered a breaking change? If not, we will need to fix this in Patcher's code, but I am not super familiar with Python releases.
***

**yorinasub17** commented *Dec 10, 2021*

Minor version increases of python are backward compatible so this is ok!
***

**Etiene** commented *Feb 25, 2022*

Kicked off the tests on this one again and they seem to be passing
***

