# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "gather_statistics() - general" {
  source "${PROJECT_ROOT}/src/validation.sh"

  INPUT_SEVERITY="style"

  run gather_statistics
  assert_failure 1

  run gather_statistics "./test/fixtures/gather_statistics/defects.log"
  assert_success
}
