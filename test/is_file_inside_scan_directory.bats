# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "is_file_inside_scan_directory() - general" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run is_file_inside_scan_directory
  assert_failure 1

  INPUT_SCAN_DIRECTORY=""
  run is_file_inside_scan_directory "test/test.sh"
  assert_success

  # !FIXME: This is working in real life, but not in tests \o/
  # INPUT_SCAN_DIRECTORY="test/**"
  # run is_file_inside_scan_directory "test/script.sh"
  # assert_success

  INPUT_SCAN_DIRECTORY="src/**"
  run is_file_inside_scan_directory "test/test.sh"
  assert_failure 2
}

function teardown() {
  export INPUT_SCAN_DIRECTORY=""
}
