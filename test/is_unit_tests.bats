# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "is_unit_tests()" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run is_unit_tests
  assert_failure 1

  UNIT_TESTS="true"
  run is_unit_tests
  assert_success
}

teardown () {
  export \
    UNIT_TESTS=""
}
