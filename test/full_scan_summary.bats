# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "full_scan_summary()" {
  source "${PROJECT_ROOT}/src/summary.sh"

  export all_scripts=("1.sh" "\$2.sh" "3 .sh")
  INPUT_TRIGGERING_EVENT=""

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

  run full_scan_summary
  assert_success
  assert_output \
"Number of scripts: \`3\`

Defects: **3**"
}

@test "full_scan_summary() - no fixes or defects" {
  source "${PROJECT_ROOT}/src/summary.sh"

  export all_scripts=("1.sh" "\$2.sh" "3 .sh")
  INPUT_TRIGGERING_EVENT=""

  touch ../defects.log ../fixes.log

  run full_scan_summary
  assert_success
  assert_output \
"Number of scripts: \`3\`

Defects: **0**"
}

@test "full_scan_summary() - no changed shell scripts" {
  source "${PROJECT_ROOT}/src/summary.sh"

  export all_scripts=()
  INPUT_TRIGGERING_EVENT=""

  touch ../defects.log ../fixes.log

  run full_scan_summary
  assert_success
  assert_output \
"Number of scripts: \`0\`

Defects: **0**"
}

teardown () {
  rm -f ../defects.log ../fixes.log

  export \
    all_scripts="" \
    INPUT_TRIGGERING_EVENT=""
}
