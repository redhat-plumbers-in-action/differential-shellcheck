<p align="center">
  <img src="https://github.com/redhat-plumbers-in-action/team/blob/70f67465cc46e02febb16aaa1cace2ceb82e6e5c/members/green-plumber.png" width="100" />
  <h1 align="center">Differential ShellCheck</h1>
</p>

[![Test Differential ShellCheck](https://github.com/redhat-plumbers-in-action/differential-shellcheck/actions/workflows/shellcheck_test.yml/badge.svg)](https://github.com/redhat-plumbers-in-action/differential-shellcheck/actions/workflows/shellcheck_test.yml)

This repository hosts code for running differential ShellCheck in GitHub actions. Idea of having something like differential ShellCheck was first introduced in [@fedora-sysv/initscripts](https://github.com/fedora-sysv/initscripts). Initscripts needed some way to verify incoming PR's without getting warnings and errors about already merged and for years working code. Therefore, differential ShellCheck was born.

## How does it work

First Differential ShellCheck gets a list of changed shell scripts based on file extensions, shebangs and script list, if provided. Then it calls [@koalaman/shellcheck](https://github.com/koalaman/shellcheck) on those scripts where it stores ShellCheck output for later use. Then it switches from `HEAD` to provided `BASE` and runs ShellCheck on the same files as before and stores output to separate file.

To evaluate results Differential ShellCheck uses utilities `csdiff` and `csgrep` from [@csutils/csdiff](https://github.com/csutils/csdiff). First is used `csdiff` to get a list/number of fixed and added errors. And then is used `csgrep` to output results in a nice colorized way.

## Features

* Shell scripts auto-detection based on shebangs (`!#/bin/sh` or `!#/bin/bash`) and file extensions (`.sh`)
* Ability to white list specific error codes
* Statistics about fixed and added errors
* Colored console output

## Usage

```yml
name: Differential ShellCheck
on:
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-20.04

    steps: 
      - name: Repository checkout
        uses: actions/checkout@v2

      - name: Differential ShellCheck
        uses: actions/differential-shellcheck@v1
```

<details>
  <summary>Output example</summary>
  <img src="doc/images/output-example.png" width="800" />
</details>

## Configuration options

Action currently accept following options:

```yml
# ...

- name: Differential ShellCheck
  uses: actions/differential-shellcheck@v1
  with:
    base: <base-sha>
    head: <head-sha>
    ignored-codes: <path to file with list of codes>
    shell-scripts: <path to file with list of scripts>

# ...
```

### base

`SHA` of commit which will be used as base when performing differential ShellCheck.

* default value: `github.event.pull_request.base.sha`
* requirements: `optional`

### head

`SHA` of commit which refers to `HEAD`.

* default value: `github.event.pull_request.head.sha`
* requirements: `optional`

### ignored-codes

Path to text file which holds a list of ShellCheck codes which should be excluded from validation.

* default value: `undefined`
* requirements: `optional`
* example: [.diff-shellcheck-exceptions.txt](.github/.diff-shellcheck-exceptions.txt)

### shell-scripts

Path to text file which holds a list of shell scripts in this repository which would not for some reason picked up by shell script auto-detection routine.

* default value: `undefined`
* requirements: `optional`
* example: [.diff-shellcheck-scripts.txt](.github/.diff-shellcheck-scripts.txt)

Note: _Every path should be absolute and placed on separate lines. Avoid spaces in list since they are counted as comment._
