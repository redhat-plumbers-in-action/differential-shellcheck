# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "print_statistics() - severity=style" {
  source "${PROJECT_ROOT}/src/validation.sh"

  INPUT_SEVERITY="style"
  gather_statistics "./test/fixtures/print_statistics/defects.log"
  run print_statistics
  assert_success
  assert_output \
"::group::📊 Statistics of defects
Error: 0
Warning: 3
Note: 0
Style: 0
::endgroup::"
}

@test "print_statistics() - severity=warning" {
  source "${PROJECT_ROOT}/src/validation.sh"

  INPUT_SEVERITY="warning"
  gather_statistics "./test/fixtures/print_statistics/defects.log"
  run print_statistics
  assert_success
  assert_output \
"::group::📊 Statistics of defects
Error: 0
Warning: 3
::endgroup::"
}
