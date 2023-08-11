# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "summary() - general" {
  source "${PROJECT_ROOT}/src/functions.sh"
  source "${PROJECT_ROOT}/src/summary.sh"

  export only_changed_scripts=("1.sh" "\$2.sh" "3 .sh")
  INPUT_TRIGGERING_EVENT=""
  INPUT_SEVERITY="style"

  echo -e \
"Error: SHELLCHECK_WARNING:
src/index.sh:53:10: warning[SC2154]: MAIN_HEADING is referenced but not assigned.

Error: SHELLCHECK_WARNING:
src/index.sh:56:14: warning[SC2154]: WHITE is referenced but not assigned.

Error: SHELLCHECK_WARNING:
src/index.sh:56:56: warning[SC2154]: NOCOLOR is referenced but not assigned.
" > ../defects.log

  echo -e \
"Error: SHELLCHECK_WARNING:
src/index.sh:7:3: note[SC1091]: Not following: functions.sh: openBinaryFile: does not exist (No such file or directory)
" > ../fixes.log

  run summary
  assert_success
  assert_output \
"### Differential ShellCheck 🐚

Changed scripts: \`3\`

|                    | ❌ Added                 | ✅ Fixed                 |
|:------------------:|:------------------------:|:------------------------:|
| ⚠️ Errors / Warnings / Notes |  **3**  |  **1**  |

#### New defects statistics

|          | 👕 Style                 | 🗒️ Note                 | ⚠️ Warning                 | 🛑 Error                 |
|:--------:|:------------------------:|:-----------------------:|:--------------------------:|:------------------------:|
| 🔢 Count | **N/A** | **N/A** | **N/A** | **N/A** |

#### Useful links

- [Differential ShellCheck Documentation](https://github.com/redhat-plumbers-in-action/differential-shellcheck#readme)
- [ShellCheck Documentation](https://github.com/koalaman/shellcheck#readme)

---
_ℹ️ If you have an issue with this GitHub action, please try to run it in the [debug mode](https://github.blog/changelog/2022-05-24-github-actions-re-run-jobs-with-debug-logging/) and submit an [issue](https://github.com/redhat-plumbers-in-action/differential-shellcheck/issues/new)._"
}

@test "summary() - TRIGGERING_EVENT = push" {
  source "${PROJECT_ROOT}/src/functions.sh"
  source "${PROJECT_ROOT}/src/summary.sh"

  export only_changed_scripts=("1.sh" "\$2.sh" "3 .sh")
  INPUT_TRIGGERING_EVENT="push"
  INPUT_SEVERITY="style"
  GITHUB_REPOSITORY="test-user/test-repo"
  GITHUB_REF_NAME="test-branch"
  SCANNING_TOOL="not-shellcheck"
  GITHUB_REF="refs/heads/${GITHUB_REF_NAME}"

  echo -e \
"Error: SHELLCHECK_WARNING:
src/index.sh:53:10: warning[SC2154]: MAIN_HEADING is referenced but not assigned.

Error: SHELLCHECK_WARNING:
src/index.sh:56:14: warning[SC2154]: WHITE is referenced but not assigned.

Error: SHELLCHECK_WARNING:
src/index.sh:56:56: warning[SC2154]: NOCOLOR is referenced but not assigned.
" > ../defects.log

  echo -e \
"Error: SHELLCHECK_WARNING:
src/index.sh:7:3: note[SC1091]: Not following: functions.sh: openBinaryFile: does not exist (No such file or directory)
" > ../fixes.log

  run summary
  assert_success
  assert_output \
"### Differential ShellCheck 🐚

Changed scripts: \`3\`

|                    | ❌ Added                 | ✅ Fixed                 |
|:------------------:|:------------------------:|:------------------------:|
| ⚠️ [Errors / Warnings / Notes](https://github.com/${GITHUB_REPOSITORY}/security/code-scanning?query=tool%3A${SCANNING_TOOL}+branch%3A${GITHUB_REF_NAME}+is%3Aopen) |  **3**  |  **1**  |

#### New defects statistics

|          | 👕 Style                 | 🗒️ Note                 | ⚠️ Warning                 | 🛑 Error                 |
|:--------:|:------------------------:|:-----------------------:|:--------------------------:|:------------------------:|
| 🔢 Count | **N/A** | **N/A** | **N/A** | **N/A** |

#### Useful links

- [Differential ShellCheck Documentation](https://github.com/redhat-plumbers-in-action/differential-shellcheck#readme)
- [ShellCheck Documentation](https://github.com/koalaman/shellcheck#readme)

---
_ℹ️ If you have an issue with this GitHub action, please try to run it in the [debug mode](https://github.blog/changelog/2022-05-24-github-actions-re-run-jobs-with-debug-logging/) and submit an [issue](https://github.com/redhat-plumbers-in-action/differential-shellcheck/issues/new)._"
}

@test "summary() - TRIGGERING_EVENT = pull_request" {
  source "${PROJECT_ROOT}/src/functions.sh"
  source "${PROJECT_ROOT}/src/summary.sh"

  export only_changed_scripts=("1.sh" "\$2.sh" "3 .sh")
  INPUT_TRIGGERING_EVENT="pull_request"
  INPUT_SEVERITY="style"
  GITHUB_REPOSITORY="test-user/test-repo"
  PR_NUMBER=123
  SCANNING_TOOL="not-shellcheck"
  GITHUB_REF="refs/pull/${PR_NUMBER}/merge"

  echo -e \
"Error: SHELLCHECK_WARNING:
src/index.sh:53:10: warning[SC2154]: MAIN_HEADING is referenced but not assigned.

Error: SHELLCHECK_WARNING:
src/index.sh:56:14: warning[SC2154]: WHITE is referenced but not assigned.

Error: SHELLCHECK_WARNING:
src/index.sh:56:56: warning[SC2154]: NOCOLOR is referenced but not assigned.
" > ../defects.log

  echo -e \
"Error: SHELLCHECK_WARNING:
src/index.sh:7:3: note[SC1091]: Not following: functions.sh: openBinaryFile: does not exist (No such file or directory)
" > ../fixes.log

  run summary
  assert_success
  assert_output \
"### Differential ShellCheck 🐚

Changed scripts: \`3\`

|                    | ❌ Added                 | ✅ Fixed                 |
|:------------------:|:------------------------:|:------------------------:|
| ⚠️ [Errors / Warnings / Notes](https://github.com/${GITHUB_REPOSITORY}/security/code-scanning?query=pr%3A${PR_NUMBER}+tool%3A${SCANNING_TOOL}+is%3Aopen) |  **3**  |  **1**  |

#### New defects statistics

|          | 👕 Style                 | 🗒️ Note                 | ⚠️ Warning                 | 🛑 Error                 |
|:--------:|:------------------------:|:-----------------------:|:--------------------------:|:------------------------:|
| 🔢 Count | **N/A** | **N/A** | **N/A** | **N/A** |

#### Useful links

- [Differential ShellCheck Documentation](https://github.com/redhat-plumbers-in-action/differential-shellcheck#readme)
- [ShellCheck Documentation](https://github.com/koalaman/shellcheck#readme)

---
_ℹ️ If you have an issue with this GitHub action, please try to run it in the [debug mode](https://github.blog/changelog/2022-05-24-github-actions-re-run-jobs-with-debug-logging/) and submit an [issue](https://github.com/redhat-plumbers-in-action/differential-shellcheck/issues/new)._"
}

@test "summary() - no fixes or defects" {
  source "${PROJECT_ROOT}/src/functions.sh"
  source "${PROJECT_ROOT}/src/summary.sh"

  export only_changed_scripts=("1.sh" "\$2.sh" "3 .sh")
  INPUT_TRIGGERING_EVENT=""
  INPUT_SEVERITY="style"

  touch ../defects.log ../fixes.log

  run summary
  assert_success
  assert_output \
"### Differential ShellCheck 🐚

Changed scripts: \`3\`

|                    | ❌ Added                 | ✅ Fixed                 |
|:------------------:|:------------------------:|:------------------------:|
| ⚠️ Errors / Warnings / Notes |  **0**  |  **0**  |

#### New defects statistics

|          | 👕 Style                 | 🗒️ Note                 | ⚠️ Warning                 | 🛑 Error                 |
|:--------:|:------------------------:|:-----------------------:|:--------------------------:|:------------------------:|
| 🔢 Count | **N/A** | **N/A** | **N/A** | **N/A** |

#### Useful links

- [Differential ShellCheck Documentation](https://github.com/redhat-plumbers-in-action/differential-shellcheck#readme)
- [ShellCheck Documentation](https://github.com/koalaman/shellcheck#readme)

---
_ℹ️ If you have an issue with this GitHub action, please try to run it in the [debug mode](https://github.blog/changelog/2022-05-24-github-actions-re-run-jobs-with-debug-logging/) and submit an [issue](https://github.com/redhat-plumbers-in-action/differential-shellcheck/issues/new)._"
}

@test "summary() - no changed shell scripts" {
  source "${PROJECT_ROOT}/src/functions.sh"
  source "${PROJECT_ROOT}/src/summary.sh"

  export only_changed_scripts=()
  INPUT_TRIGGERING_EVENT=""
  INPUT_SEVERITY="style"

  touch ../defects.log ../fixes.log

  run summary
  assert_success
  assert_output \
"### Differential ShellCheck 🐚

Changed scripts: \`0\`

|                    | ❌ Added                 | ✅ Fixed                 |
|:------------------:|:------------------------:|:------------------------:|
| ⚠️ Errors / Warnings / Notes |  **0**  |  **0**  |

#### New defects statistics

|          | 👕 Style                 | 🗒️ Note                 | ⚠️ Warning                 | 🛑 Error                 |
|:--------:|:------------------------:|:-----------------------:|:--------------------------:|:------------------------:|
| 🔢 Count | **N/A** | **N/A** | **N/A** | **N/A** |

#### Useful links

- [Differential ShellCheck Documentation](https://github.com/redhat-plumbers-in-action/differential-shellcheck#readme)
- [ShellCheck Documentation](https://github.com/koalaman/shellcheck#readme)

---
_ℹ️ If you have an issue with this GitHub action, please try to run it in the [debug mode](https://github.blog/changelog/2022-05-24-github-actions-re-run-jobs-with-debug-logging/) and submit an [issue](https://github.com/redhat-plumbers-in-action/differential-shellcheck/issues/new)._"
}

@test "summary() - FULL_SCAN = true" {
  source "${PROJECT_ROOT}/src/functions.sh"
  source "${PROJECT_ROOT}/src/summary.sh"

  export all_scripts=("1.sh" "\$2.sh" "3 .sh")
  INPUT_TRIGGERING_EVENT=""
  INPUT_SEVERITY="style"
  FULL_SCAN=0

  echo -e \
"Error: SHELLCHECK_WARNING:
src/index.sh:53:10: warning[SC2154]: MAIN_HEADING is referenced but not assigned.

Error: SHELLCHECK_WARNING:
src/index.sh:56:14: warning[SC2154]: WHITE is referenced but not assigned.

Error: SHELLCHECK_WARNING:
src/index.sh:56:56: warning[SC2154]: NOCOLOR is referenced but not assigned.
" > ../defects.log

  echo -e \
"Error: SHELLCHECK_WARNING:
src/index.sh:7:3: note[SC1091]: Not following: functions.sh: openBinaryFile: does not exist (No such file or directory)
" > ../fixes.log

  run summary
  assert_success
  assert_output \
"### Differential ShellCheck 🐚

Changed scripts: \`0\`

|                    | ❌ Added                 | ✅ Fixed                 |
|:------------------:|:------------------------:|:------------------------:|
| ⚠️ Errors / Warnings / Notes |  **3**  |  **1**  |

#### New defects statistics

|          | 👕 Style                 | 🗒️ Note                 | ⚠️ Warning                 | 🛑 Error                 |
|:--------:|:------------------------:|:-----------------------:|:--------------------------:|:------------------------:|
| 🔢 Count | **N/A** | **N/A** | **N/A** | **N/A** |

#### Useful links

- [Differential ShellCheck Documentation](https://github.com/redhat-plumbers-in-action/differential-shellcheck#readme)
- [ShellCheck Documentation](https://github.com/koalaman/shellcheck#readme)

---
_ℹ️ If you have an issue with this GitHub action, please try to run it in the [debug mode](https://github.blog/changelog/2022-05-24-github-actions-re-run-jobs-with-debug-logging/) and submit an [issue](https://github.com/redhat-plumbers-in-action/differential-shellcheck/issues/new)._"
}

@test "summary() - FULL_SCAN = true && is_strict_check_on_push_demanded = true" {
  source "${PROJECT_ROOT}/src/functions.sh"
  source "${PROJECT_ROOT}/src/summary.sh"

  export all_scripts=("1.sh" "\$2.sh" "3 .sh")
  INPUT_TRIGGERING_EVENT="push"
  INPUT_SEVERITY="style"
  GITHUB_REPOSITORY="test-user/test-repo"
  GITHUB_REF_NAME="test-branch"
  SCANNING_TOOL="not-shellcheck"
  GITHUB_REF="refs/heads/${GITHUB_REF_NAME}"
  FULL_SCAN=0
  INPUT_STRICT_CHECK_ON_PUSH="true"

  echo -e \
"Error: SHELLCHECK_WARNING:
src/index.sh:53:10: warning[SC2154]: MAIN_HEADING is referenced but not assigned.

Error: SHELLCHECK_WARNING:
src/index.sh:56:14: warning[SC2154]: WHITE is referenced but not assigned.

Error: SHELLCHECK_WARNING:
src/index.sh:56:56: warning[SC2154]: NOCOLOR is referenced but not assigned.
" > ../defects.log

  echo -e \
"Error: SHELLCHECK_WARNING:
src/index.sh:7:3: note[SC1091]: Not following: functions.sh: openBinaryFile: does not exist (No such file or directory)
" > ../fixes.log

  run summary
  assert_success
  assert_output \
"### Differential ShellCheck 🐚

Number of scripts: \`3\`

[Defects](https://github.com/${GITHUB_REPOSITORY}/security/code-scanning?query=tool%3A${SCANNING_TOOL}+branch%3A${GITHUB_REF_NAME}+is%3Aopen): **3**

#### New defects statistics

|          | 👕 Style                 | 🗒️ Note                 | ⚠️ Warning                 | 🛑 Error                 |
|:--------:|:------------------------:|:-----------------------:|:--------------------------:|:------------------------:|
| 🔢 Count | **N/A** | **N/A** | **N/A** | **N/A** |

#### Useful links

- [Differential ShellCheck Documentation](https://github.com/redhat-plumbers-in-action/differential-shellcheck#readme)
- [ShellCheck Documentation](https://github.com/koalaman/shellcheck#readme)

---
_ℹ️ If you have an issue with this GitHub action, please try to run it in the [debug mode](https://github.blog/changelog/2022-05-24-github-actions-re-run-jobs-with-debug-logging/) and submit an [issue](https://github.com/redhat-plumbers-in-action/differential-shellcheck/issues/new)._"
}

teardown () {
  rm -f ../defects.log ../fixes.log

  export \
    only_changed_scripts="" \
    INPUT_TRIGGERING_EVENT="" \
    INPUT_SEVERITY="" \
    GITHUB_REPOSITORY="" \
    GITHUB_REF_NAME="" \
    SCANNING_TOOL="" \
    GITHUB_REF="" \
    PR_NUMBER="" \
    FULL_SCAN="" \
    INPUT_STRICT_CHECK_ON_PUSH=""
}
