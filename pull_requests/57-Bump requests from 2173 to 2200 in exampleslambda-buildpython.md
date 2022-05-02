# Bump requests from 2.17.3 to 2.20.0 in /examples/lambda-build/python

**dependabot[bot]** commented *Nov 20, 2020*

Bumps [requests](https://github.com/psf/requests) from 2.17.3 to 2.20.0.
<details>
<summary>Changelog</summary>
<p><em>Sourced from <a href="https://github.com/psf/requests/blob/master/HISTORY.md">requests's changelog</a>.</em></p>
<blockquote>
<h2>2.20.0 (2018-10-18)</h2>
<p><strong>Bugfixes</strong></p>
<ul>
<li>Content-Type header parsing is now case-insensitive (e.g.
charset=utf8 v Charset=utf8).</li>
<li>Fixed exception leak where certain redirect urls would raise
uncaught urllib3 exceptions.</li>
<li>Requests removes Authorization header from requests redirected
from https to http on the same hostname. (CVE-2018-18074)</li>
<li><code>should_bypass_proxies</code> now handles URIs without hostnames (e.g.
files).</li>
</ul>
<p><strong>Dependencies</strong></p>
<ul>
<li>Requests now supports urllib3 v1.24.</li>
</ul>
<p><strong>Deprecations</strong></p>
<ul>
<li>Requests has officially stopped support for Python 2.6.</li>
</ul>
<h2>2.19.1 (2018-06-14)</h2>
<p><strong>Bugfixes</strong></p>
<ul>
<li>Fixed issue where status_codes.py's <code>init</code> function failed trying
to append to a <code>__doc__</code> value of <code>None</code>.</li>
</ul>
<h2>2.19.0 (2018-06-12)</h2>
<p><strong>Improvements</strong></p>
<ul>
<li>Warn user about possible slowdown when using cryptography version
&lt; 1.3.4</li>
<li>Check for invalid host in proxy URL, before forwarding request to
adapter.</li>
<li>Fragments are now properly maintained across redirects. (RFC7231
7.1.2)</li>
<li>Removed use of cgi module to expedite library load time.</li>
<li>Added support for SHA-256 and SHA-512 digest auth algorithms.</li>
<li>Minor performance improvement to <code>Request.content</code>.</li>
<li>Migrate to using collections.abc for 3.7 compatibility.</li>
</ul>
<p><strong>Bugfixes</strong></p>
<ul>
<li>Parsing empty <code>Link</code> headers with <code>parse_header_links()</code> no longer
return one bogus entry.</li>
</ul>
<!-- raw HTML omitted -->
</blockquote>
<p>... (truncated)</p>
</details>
<details>
<summary>Commits</summary>
<ul>
<li><a href="https://github.com/psf/requests/commit/bd840450c0d1e9db3bf62382c15d96378cc3a056"><code>bd84045</code></a> v2.20.0</li>
<li><a href="https://github.com/psf/requests/commit/7fd9267b3bab1d45f5e4ac0953629c5531ecbc55"><code>7fd9267</code></a> remove final remnants from 2.6</li>
<li><a href="https://github.com/psf/requests/commit/6ae8a2189235b62d7c5b2a6b95528750f046097c"><code>6ae8a21</code></a> Add myself to AUTHORS</li>
<li><a href="https://github.com/psf/requests/commit/89ab030cdb83a728a30e172bc65d27ba214d2eda"><code>89ab030</code></a> Use comprehensions whenever possible</li>
<li><a href="https://github.com/psf/requests/commit/2c6a8426aebd853966747f2c851f551c583cb21a"><code>2c6a842</code></a> Merge pull request <a href="https://github-redirect.dependabot.com/psf/requests/issues/4827">#4827</a> from webmaven/patch-1</li>
<li><a href="https://github.com/psf/requests/commit/30be889651e7034eaa56edaf5794d68ffbfde9ed"><code>30be889</code></a> CVE URLs update: www sub-subdomain no longer valid</li>
<li><a href="https://github.com/psf/requests/commit/a6cd380c640087218695bc7c62311a4843777e43"><code>a6cd380</code></a> Merge pull request <a href="https://github-redirect.dependabot.com/psf/requests/issues/4765">#4765</a> from requests/encapsulate_urllib3_exc</li>
<li><a href="https://github.com/psf/requests/commit/bbdbcc8f0553f112ff68b0950b4128bd8af000fc"><code>bbdbcc8</code></a> wrap url parsing exceptions from urllib3's PoolManager</li>
<li><a href="https://github.com/psf/requests/commit/ff0c325014f817095de35013d385e137b111d6e8"><code>ff0c325</code></a> Merge pull request <a href="https://github-redirect.dependabot.com/psf/requests/issues/4805">#4805</a> from jdufresne/https</li>
<li><a href="https://github.com/psf/requests/commit/b0ad2499c8641d29affc90f565e6628d333d2a96"><code>b0ad249</code></a> Prefer https:// for URLs throughout project</li>
<li>Additional commits viewable in <a href="https://github.com/psf/requests/compare/v2.17.3...v2.20.0">compare view</a></li>
</ul>
</details>
<br />


[![Dependabot compatibility score](https://dependabot-badges.githubapp.com/badges/compatibility_score?dependency-name=requests&package-manager=pip&previous-version=2.17.3&new-version=2.20.0)](https://docs.github.com/en/github/managing-security-vulnerabilities/configuring-github-dependabot-security-updates)

Dependabot will resolve any conflicts with this PR as long as you don't alter it yourself. You can also trigger a rebase manually by commenting `@dependabot rebase`.

[//]: # (dependabot-automerge-start)
[//]: # (dependabot-automerge-end)

---

<details>
<summary>Dependabot commands and options</summary>
<br />

You can trigger Dependabot actions by commenting on this PR:
- `@dependabot rebase` will rebase this PR
- `@dependabot recreate` will recreate this PR, overwriting any edits that have been made to it
- `@dependabot merge` will merge this PR after your CI passes on it
- `@dependabot squash and merge` will squash and merge this PR after your CI passes on it
- `@dependabot cancel merge` will cancel a previously requested merge and block automerging
- `@dependabot reopen` will reopen this PR if it is closed
- `@dependabot close` will close this PR and stop Dependabot recreating it. You can achieve the same result by closing it manually
- `@dependabot ignore this major version` will close this PR and stop Dependabot creating any more for this major version (unless you reopen the PR or upgrade to it yourself)
- `@dependabot ignore this minor version` will close this PR and stop Dependabot creating any more for this minor version (unless you reopen the PR or upgrade to it yourself)
- `@dependabot ignore this dependency` will close this PR and stop Dependabot creating any more for this dependency (unless you reopen the PR or upgrade to it yourself)
- `@dependabot use these labels` will set the current labels as the default for future PRs for this repo and language
- `@dependabot use these reviewers` will set the current reviewers as the default for future PRs for this repo and language
- `@dependabot use these assignees` will set the current assignees as the default for future PRs for this repo and language
- `@dependabot use this milestone` will set the current milestone as the default for future PRs for this repo and language

You can disable automated security fix PRs for this repo from the [Security Alerts page](https://github.com/gruntwork-io/package-lambda/network/alerts).

</details>
<br />
***


**dependabot[bot]** commented *Oct 8, 2021*

Looks like requests is up-to-date now, so this is no longer needed.
***

