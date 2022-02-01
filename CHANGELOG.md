# Changelog

## NEXT

* Use [@actions/toolkit](https://github.com/actions/toolkit) and [@probot/probot](https://github.com/probot/probot) instead of currently used `bash` and `Docker`.
* Improve usability - human readable and accessible output in form of comments, suggestions, etc.
* More customization - whitelisting and blacklisting of error codes and scripts
* And more...

## v1

* Initial release
* Shell scripts auto-detection based on shebangs (`!#/bin/sh` or `!#/bin/bash`) and file extensions (`.sh`)
* Ability to white list specific error codes
* Statistics about fixed and added errors
* Colored console output
