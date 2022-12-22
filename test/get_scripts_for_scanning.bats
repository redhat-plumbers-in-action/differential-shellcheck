# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "get_scripts_for_scanning()" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run get_scripts_for_scanning
  assert_failure 1

  run get_scripts_for_scanning "path"
  assert_failure 1

  shell_scripts=()
  run get_scripts_for_scanning "./test/fixtures/get_scripts_for_scanning/files.txt" "shell_scripts"
  assert_success
  #! FIXME for some reason I can't get assert_equal to work
  # assert_equal "${shell_scripts[*]}" "./test/fixtures/get_scripts_for_scanning/script1.sh ./test/fixtures/get_scripts_for_scanning/script2"
}

teardown () {
  export \
    shell_scripts=""
}
