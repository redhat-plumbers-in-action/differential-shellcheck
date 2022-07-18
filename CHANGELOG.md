# Changelog

## NEXT

* Use [@actions/toolkit](https://github.com/actions/toolkit) and [@probot/probot](https://github.com/probot/probot) instead of currently used `bash` and `Docker`.
* Improve usability - human readable and accessible output in form of comments, suggestions, etc.
* More customization - allowlisting and denylisting of error codes and scripts
* And more...

## v2.3.1 ... v2.3.3

* Fix release automation
* Action should now work as before, but faster

## v2.3.0

* Use pre-build containers to improve performance of action

## v2.2.0

* Added option to run in debug mode - more verbose output
* Output optimizations - cleaner output, emojis, updated colors and spacing
* Support for job summaries
* Added support for `.bash` extensions
* Added unit tests and code coverage
* Added codebase linter

## v2.1.1

* Small documentation changes

## v2.1.0

* SARIF feature now supports PRs from private forks

## v2.0.0

* Added support for SARIF

## v1.2.0

* Fix wrong check in `clean_array()`
* Action cannot be run on `push`
* Cleanup code from redundant variables
* Use `fedora:latest` container image instead of `rawhide`

## v1.1.3

* Update of documentation

## v1.1.2

* Bugfixes:
  * Make directory /github/workspace git-save
  * Remove double quotes to avoid git empty pathspec warnings
* Make GA tests ran on current version of repo/fork
* Bump actions/checkout from 2 to 3

## v1.1.1

* Minor changes regarding internal automation

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
