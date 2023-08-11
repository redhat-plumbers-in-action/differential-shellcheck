# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "get_number_of_defects_by_severity() - general" {
  source "${PROJECT_ROOT}/src/validation.sh"

  run get_number_of_defects_by_severity
  assert_failure 1

  run get_number_of_defects_by_severity "arg1"
  assert_failure 1

  run get_number_of_defects_by_severity "warning" "./test/fixtures/get_number_of_defects_by_severity/defects.log"
  assert_success
  assert_output "3"

  run get_number_of_defects_by_severity "error" "./test/fixtures/get_number_of_defects_by_severity/defects.log"
  assert_success
  assert_output "0"
}
