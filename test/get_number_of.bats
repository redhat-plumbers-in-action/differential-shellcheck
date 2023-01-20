# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "get_number_of() - arguments" {
  source "${PROJECT_ROOT}/src/summary.sh"

  run get_number_of
  assert_failure 1
}

@test "get_number_of() - defects" {
  source "${PROJECT_ROOT}/src/summary.sh"

  echo -e \
"Error: SHELLCHECK_WARNING:
src/index.sh:53:10: warning[SC2154]: MAIN_HEADING is referenced but not assigned.

Error: SHELLCHECK_WARNING:
src/index.sh:56:14: warning[SC2154]: WHITE is referenced but not assigned.

Error: SHELLCHECK_WARNING:
src/index.sh:56:56: warning[SC2154]: NOCOLOR is referenced but not assigned.
" > ../defects.log

  run get_number_of "defects"
  assert_success
  assert_output "3"
}

@test "get_number_of() - fixes" {
  source "${PROJECT_ROOT}/src/summary.sh"

  echo -e \
"Error: SHELLCHECK_WARNING:
src/index.sh:7:3: note[SC1091]: Not following: functions.sh: openBinaryFile: does not exist (No such file or directory)
" > ../fixes.log

  run get_number_of "fixes"
  assert_success
  assert_output "1"
}

teardown () {
  rm -f ../fixes.log ../defects.log
}
