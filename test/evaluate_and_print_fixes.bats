# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "evaluate_and_print_fixes() - some fixes" {
  source "${PROJECT_ROOT}/src/validation.sh"

  INPUT_SEVERITY="style"
  cp ./test/fixtures/evaluate_and_print_fixes/fixes.log ../fixes.log

  run evaluate_and_print_fixes
  assert_success
  assert_output --partial "✅ Fixed defects
Error: SHELLCHECK_WARNING:
innocent-script.sh:6: warning[SC2034]: UNUSED_VAR appears unused. Verify use (or export if used externally)."
}

@test "evaluate_and_print_fixes() - no fixes" {
  source "${PROJECT_ROOT}/src/validation.sh"

  run evaluate_and_print_fixes
  assert_success
  assert_output "ℹ️ No Fixes!"
}

teardown () {
  rm -f ../fixes.log
}
