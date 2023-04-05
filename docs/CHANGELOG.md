# Changelog

## v4.2.0

* New option `exclude-path`. Allows to specify list of paths excluded from ShellCheck scanning. It supports globbing and brace expansion. e.g. `test/{test1,test2}/**`

## v4.1.0

* `grep` - do not escape `#` and `!` in patterns
* Utilize `DEBUG` to run `grep` without `--silent` option
* Update `csutils` (`csdiff`) to 3.0.0

## v4.0.2

* Correctly handle character escaping in filenames (e.g. `␣` and `&`)
* Improve documentation and more tests

## v4.0.0

* Tag `latest` is no longer available. Use major tags instead (e.g. `v3` or `v4`).
* Action can be triggered using GitHub `push` event

  ```yaml
  on:
    push:

  jobs:
    lint:
      runs-on: ubuntu-latest

      steps:
        - uses: actions/checkout@v3
          with:
            fetch-depth: 0

        - uses: redhat-plumbers-in-action/differential-shellcheck@v4
          id: ShellCheck
          with:
            token: ${{ secrets.GITHUB_TOKEN }}
  ```

  > **Note**: When using `--force` action doesn't work properly when triggered on `push` events

* Action now perform full scans on `push` event by default and on `manual` trigger when requested
* Addition of new Summary page for full scans
* SARIF file is now exposed under output `sarif` for further use.

  ```yaml
    - if: ${{ always() }}
      name: Upload artifact with defects in SARIF format
      uses: actions/upload-artifact@v3
      with:
        name: Differential ShellCheck SARIF
        path: ${{ steps.ShellCheck.outputs.sarif }}
        retention-days: 7
  ```

* Removal of unused output - `ENV.LIST_OF_SCRIPTS`
* Increased code coverage
* Some minor bugfixes, ShellCheck fixes, and CI updates

## v3.3.0

* Container images now based on Fedora 37
* `ShellCheck` - `0.7.2 -> 0.8.0`
* Show versions of ShellCheck and csutils in logs
* `csutils` - `2.7.0 -> 2.8.0`
  * Added ability to overwrite scan tool properties - `csgrep --set-scan-prop`

## v3.2.0

* `csutils` - `2.6.0 -> 2.7.0`
  * Added support for SARIF severity levels

## v3.1.1

* Documentation updates (`.shellcheckrc`, examples, etc.)
* Skip checking of symbolic links

## v3.1.0

* Autodetection: add support for `emacs` and `vi/vim` file types specifications
  * `emacs` - `# -*- sh -*-`
  * `vi`    - `# vi: (set)? (ft|filetype)=sh`
  * `vim`   - `# vim: (set)? (ft|filetype)=sh`
* Further improved autodetection of shell scripts based on shebangs and ShellCheck directives

## v3.0.0

* Add option `external-sources` and enable it by default

## v2.5.1

* `ignored-codes` option is now marked as deprecated and may be removed in future major release. Please consider using `.shellcheckrc` instead.

## v2.5.0

* Add support for severity option, supported values are: `error`, `warning`, `info` and `style`

## v2.4.0

* Support for `ash`, `dash`, `ksh` and `bats` shell interpreters
* Improve autodetection of shell scripts
  * Support for detection based on ShellCheck directive ; e.g. `# shellcheck shell=bash`
  * Support for generally used shebang prefixes like: `#!/usr/bin`, `#!/usr/local/bin`, `#!/bin/env␣`, `#!/usr/bin/env␣` and `#!/usr/local/bin/env␣` ; e.g. `#!/bin/env␣bash`

## v2.3.6

* Fix tool name in SARIF reports

## v2.3.5

* Update permissions in examples

## v2.3.4

* Fix typos, grammar mistakes and reword some sentences
* Update image examples to support light/dark modes

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
