# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "file_to_array() - arguments" {
  source "${PROJECT_ROOT}/src/functions.sh"

  touch file.txt

  file_array=()
  run file_to_array "file.txt"
  assert_failure 1
  assert_equal "${file_array[*]}" ""
}

# !FIXME - file_to_array() should succes when provided with empty file
@test "file_to_array() - empty file" {
  source "${PROJECT_ROOT}/src/functions.sh"

  touch file.txt

  file_array=()
  run file_to_array "file.txt" "file_array"
  # assert_success
  assert_equal "${file_array[*]}" ""
}

@test "file_to_array() - general" {
  source "${PROJECT_ROOT}/src/functions.sh"

  UNIT_TESTS=0

  file_array=()
  run file_to_array "./test/fixtures/file_to_array/files.txt" "file_array"
  assert_success
  assert_output "test/fixtures/get_scripts_for_scanning/files.txt test/fixtures/get_scripts_for_scanning/non-script.md test/fixtures/get_scripts_for_scanning/script1.sh test/fixtures/get_scripts_for_scanning/script2 test/fixtures/get_scripts_for_scanning/script 2.sh test/fixtures/get_scripts_for_scanning/script&3.sh test/fixtures/get_scripts_for_scanning/\$script4.sh test/fixtures/get_scripts_for_scanning/dm-back\\x2dslash.swap"
}

teardown () {
  rm -f file.txt
}
