# Changelog

## NEXT

* Use [@actions/toolkit](https://github.com/actions/toolkit) and [@probot/probot](https://github.com/probot/probot) instead of currently used `bash` and `Docker`.
* Improve usability - human readable and accessible output in form of comments, suggestions, etc.
* More customization - whitelisting and blacklisting of error codes and scripts
* And more...

## v1.1.0

* Introduction of automation
* [@Dependabot](https://docs.github.com/en/code-security/supply-chain-security/keeping-your-dependencies-updated-automatically/configuration-options-for-dependency-updates) configuration
* [@Mergify](https://docs.mergify.com/) configuration
* [@release-drafter](https://github.com/release-drafter/release-drafter) configuration
* documentation fixes
* Major versions (`v1`, `v2`, ...) are now released automatically

## v1.0.0

* Initial release
* Shell scripts auto-detection based on shebangs (`!#/bin/sh` or `!#/bin/bash`) and file extensions (`.sh`)
* Ability to white list specific error codes
* Statistics about fixed and added errors
* Colored console output
