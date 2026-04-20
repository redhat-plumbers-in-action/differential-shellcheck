---
title: DIFFERENTIAL-SHELLCHECK
section: 1
header: User Commands
footer: differential-shellcheck
date: 2026-04-17
---

# NAME

differential-shellcheck - differential static analysis for shell scripts

# SYNOPSIS

**differential-shellcheck** [*OPTIONS*] [**--**] [*FILE* ...]

# DESCRIPTION

**differential-shellcheck** performs differential ShellCheck scans on shell
scripts in a Git repository. It identifies new defects introduced by recent
changes and fixes that were resolved, making it easy to focus on newly
introduced issues without being overwhelmed by pre-existing problems.

When run without *FILE* arguments in a Git repository, it scans changes
between a base commit (auto-detected from the upstream or origin remote)
and HEAD. When *FILE* arguments are provided, it performs a differential
scan of those files against their Git-stashed versions, making it suitable
as a **pre-commit** hook.

The tool can also be used as a GitHub Action. See the project documentation
for details.

# OPTIONS

## Differential Scan

**--base** *SHA*
:   Base commit for differential scan. Default: auto-detected from the upstream
    remote using **git-merge-base**(1).

**--head** *SHA*
:   Head commit for differential scan. Default: HEAD.

**--upstream** *REMOTE*
:   Git remote to diff against. The tool looks for a remote named "upstream"
    first, then falls back to "origin". Use this option to specify a different
    remote.

## Full Scan

**--full-scan**
:   Scan all detected shell scripts without performing a differential
    comparison. Reports all defects found. When combined with *FILE*
    arguments, scans only the listed files.

## ShellCheck Options

**--severity** *LEVEL*
:   Minimum severity of errors to consider. Valid values in order of severity
    are **error**, **warning**, **info**, and **style**. Default: **style**.

**--external-sources**
:   Follow source statements even when the file is not specified as input.
    This is the default behavior.

**--no-external-sources**
:   Do not follow source statements.

## Filtering

**--scan-directory** *DIR*
:   Limit scanning to files inside *DIR*.

**--exclude-path** *PATTERN*
:   Exclude files matching *PATTERN* from scanning. Can be specified multiple
    times.

**--include-path** *PATTERN*
:   Force include files matching *PATTERN* for scanning. Can be specified
    multiple times.

## Output

**--display-engine** *ENGINE*
:   Tool used to display defects. Valid values are **csgrep** and **sarif-fmt**.
    Default: **csgrep**.

## General

**--verbose**
:   Enable verbose/debug output.

**--version**
:   Show version information and exit.

**--help**
:   Show help message and exit.

# OPERATING MODES

**differential-shellcheck** supports three operating modes:

## Commit-range differential scan (default)

When run without *FILE* arguments, the tool identifies shell scripts that
changed between two commits and performs a differential ShellCheck scan:

    differential-shellcheck
    differential-shellcheck --base abc123 --head def456
    differential-shellcheck --upstream my-remote

## Working-tree differential scan

When *FILE* arguments are provided without **--full-scan**, the tool performs
a differential scan using **git-stash**(1) to compare the current working tree
against the stashed (base) version:

    differential-shellcheck script.sh lib.sh

This mode is used by **pre-commit** hooks.

## Full scan

With **--full-scan**, the tool scans all detected shell scripts (or only
the listed files) without differential comparison:

    differential-shellcheck --full-scan
    differential-shellcheck --full-scan script.sh

# ENVIRONMENT VARIABLES

For backward compatibility with the GitHub Action, the following environment
variables are recognized. CLI arguments take precedence.

**INPUT_TRIGGERING_EVENT**
:   Triggering event type (merge_group, pull_request, push, manual).

**INPUT_BASE**, **INPUT_HEAD**
:   Base and head commit hashes.

**INPUT_SEVERITY**
:   Minimum severity level.

**INPUT_EXTERNAL_SOURCES**
:   Follow source statements (true/false).

**INPUT_SCAN_DIRECTORY**
:   Directory to scan.

**INPUT_EXCLUDE_PATH**, **INPUT_INCLUDE_PATH**
:   Paths to exclude or include.

**INPUT_DISPLAY_ENGINE**
:   Display engine (csgrep/sarif-fmt).

**INPUT_DIFF_SCAN**
:   Whether to perform differential scan (true/false).

# EXIT STATUS

**0**
:   No defects found.

**1**
:   Defects found (needs inspection).

**2**
:   Error in arguments or configuration.

# EXAMPLES

Scan changes not yet in upstream:

    differential-shellcheck

Scan changes between two specific commits:

    differential-shellcheck --base main --head feature-branch

Scan only warnings and errors:

    differential-shellcheck --severity warning

Full scan of a specific file:

    differential-shellcheck --full-scan myscript.sh

Use as a pre-commit hook (files passed as arguments):

    differential-shellcheck script1.sh script2.sh

# PRE-COMMIT INTEGRATION

Add to your **.pre-commit-config.yaml**:

    repos:
    - repo: https://github.com/redhat-plumbers-in-action/differential-shellcheck
      rev: v5.6.0
      hooks:
      - id: differential-shellcheck

# DEPENDENCIES

**shellcheck**(1), **csdiff**(1), **csgrep**(1), **jq**(1), **git**(1)

Optional: **sarif-fmt** (alternative display engine), **cshtml** (HTML output)

# SEE ALSO

**shellcheck**(1), **csdiff**(1)

Project homepage: <https://github.com/redhat-plumbers-in-action/differential-shellcheck>

ShellCheck wiki: <https://www.shellcheck.net/wiki/>

# LICENSE

GPL-3.0-or-later

# AUTHORS

Maintained by the Red Hat Plumbers in Action team.
