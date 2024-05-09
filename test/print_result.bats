# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "print_result() - arguments" {
  source "${PROJECT_ROOT}/src/functions.sh"
  source "${PROJECT_ROOT}/src/validation.sh"

  INPUT_DISPLAY_ENGINE="csgrep"
  run print_result
  assert_failure 1

  run print_result "./test/fixtures/print_result/defects.log"
  assert_failure 1

  run print_result "./test/fixtures/print_result/defects.log" "4"
  assert_success

  INPUT_DISPLAY_ENGINE="sarif-fmt"
  run print_result "./test/fixtures/print_result/defects.log"
  assert_success
}

@test "print_result() - csgrep" {
  source "${PROJECT_ROOT}/src/validation.sh"

  INPUT_DISPLAY_ENGINE="csgrep"
  run print_result "./test/fixtures/print_result/defects.log" "4"
  assert_success
  assert_output \
'Error: SHELLCHECK_WARNING:
innocent-script.sh:7: warning[SC2034]: UNUSED_VAR2 appears unused. Verify use (or export if used externally).

Error: SHELLCHECK_WARNING:
innocent-script.sh:11: warning[SC2115]: Use "${var:?}" to ensure this never expands to / .

Error: SHELLCHECK_WARNING:
innocent-script.sh:11: warning[SC2115]: Use "${var:?}" to ensure this never expands to / .'

  run print_result "./test/fixtures/print_result/fixes.log" "2"
  assert_success
  assert_output \
'Error: SHELLCHECK_WARNING:
innocent-script.sh:7: warning[SC2034]: UNUSED_VAR2 appears unused. Verify use (or export if used externally).

Error: SHELLCHECK_WARNING:
innocent-script.sh:11: warning[SC2115]: Use "${var:?}" to ensure this never expands to / .'
}

@test "print_result() - sarif-fmt" {
  source "${PROJECT_ROOT}/src/functions.sh"
  source "${PROJECT_ROOT}/src/validation.sh"

  UNIT_TESTS="true"
  INPUT_DISPLAY_ENGINE="sarif-fmt"
  run print_result "./test/fixtures/print_result/defects.log"
  assert_success
  assert_output \
'warning: UNUSED_VAR2 appears unused. Verify use (or export if used externally).

warning: Use "${var:?}" to ensure this never expands to / .

warning: Use "${var:?}" to ensure this never expands to / .

warning: 3 warnings emitted'

  run print_result "./test/fixtures/print_result/fixes.log"
  assert_success
  assert_output \
'warning: UNUSED_VAR2 appears unused. Verify use (or export if used externally).

warning: Use "${var:?}" to ensure this never expands to / .

warning: 2 warnings emitted'
}

teardown () {
  export \
    INPUT_DISPLAY_ENGINE="" \
    UNIT_TESTS=""
  rm -f tmp.sarif
}
