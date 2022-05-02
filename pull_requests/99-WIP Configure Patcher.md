# [WIP] Configure Patcher

**marinalimeira** commented *Jan 6, 2022*

<!--
  Have any questions? Check out the contributing docs at https://docs.gruntwork.io/guides/contributing/, or
  ask in this Pull Request and a Gruntwork core maintainer will be happy to help :)
  Note: Remember to add '[WIP]' to the beginning of the title if this PR is still a work-in-progress.
-->

## Description

Add matches for the custom regex.


<!--
  If this is a feature PR, then where is it documented?

  - If docs exist:
    - Update any references, if relevant.
  - If no docs exist:
    - Create a stub for documentation including bullet points for how to use the feature, code snippets (including from happy path tests), etc.
-->

<!-- Important: Did you make any backwards incompatible changes? If yes, then you must write a migration guide! -->

## TODOs

- [ ] Ensure the branch is named correctly with the issue number. e.g: `feature/new-vpc-endpoints-955` or `bug/missing-count-param-434`.
- [ ] Update the docs.
- [ ] Keep the changes backwards compatible where possible.
- [ ] Run the pre-commit checks successfully.
- [ ] Run the relevant tests successfully.
- [ ] Ensure any 3rd party code adheres with our license policy: https://www.notion.so/gruntwork/Gruntwork-licenses-and-open-source-usage-policy-f7dece1f780341c7b69c1763f22b1378
- [ ] _Maintainers Only._ If necessary, release a new version of this repo.
- [ ] _Maintainers Only._ If there were backwards incompatible changes, include a migration guide in the release notes.
- [ ] _Maintainers Only._ Add to the next version of the monthly newsletter (see https://www.notion.so/gruntwork/Monthly-Newsletter-9198cbe7f8914d4abce23dca7b435f43).


## Related Issues

Depends on https://github.com/gruntwork-io/patcher/issues/38
<!--
  Link to the issue that is fixed by this PR (if there is one)
  e.g. Fixes #1234

  Link to an issue that is partially addressed by this PR (if there are any)
  e.g. Addresses #1234

  Link to related issues (if there are any)
  e.g. Related to #1234
-->

<br />
***


**marinalimeira** commented *Jan 6, 2022*

Hey @infraredgirl, this PR depends on https://github.com/gruntwork-io/patcher/issues/38, I will have to update it with the format you change for the regexes.
***

**infraredgirl** commented *Jan 7, 2022*

> Hey @infraredgirl, this PR depends on [gruntwork-io/patcher#38](https://github.com/gruntwork-io/patcher/issues/38), I will have to update it with the format you change for the regexes.

For the record, the planned format change in https://github.com/gruntwork-io/patcher/issues/38 will be simply replacing `renovate.json` with `patcher` everywhere in the comment strings. This coupled with the change in the regex to ensure these strings get matched is all that's needed in that ticket, as far as I understand.
***

