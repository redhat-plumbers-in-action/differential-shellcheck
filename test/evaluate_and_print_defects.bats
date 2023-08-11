# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "evaluate_and_print_defects() - some defects" {
  source "${PROJECT_ROOT}/src/validation.sh"

  INPUT_SEVERITY="style"
  cp ./test/fixtures/evaluate_and_print_defects/defects.log ../defects.log

  run evaluate_and_print_defects
  assert_failure 1
  assert_output "\
::group::📊 Statistics of defects
Error: 0
Warning: 3
Note: 0
Style: 0
::endgroup::

✋ Defects, NEEDS INSPECTION
Error: SHELLCHECK_WARNING:
src/index.sh:53:10: warning[SC2154]: MAIN_HEADING is referenced but not assigned.

Error: SHELLCHECK_WARNING:
src/index.sh:56:14: warning[SC2154]: WHITE is referenced but not assigned.

Error: SHELLCHECK_WARNING:
src/index.sh:56:56: warning[SC2154]: NOCOLOR is referenced but not assigned."
}

@test "evaluate_and_print_defects() - no defects" {
  source "${PROJECT_ROOT}/src/validation.sh"

  run evaluate_and_print_defects
  assert_success
  assert_output "🥳 No defects added. Yay!"
}

teardown () {
  rm -f ../defects.log
}
