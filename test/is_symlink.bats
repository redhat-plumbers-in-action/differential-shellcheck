# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "is_symlink()" {
  source "${PROJECT_ROOT}/src/functions.sh"

  touch file.txt
  ln -s file.txt link.txt

  run is_symlink "link.txt"
  assert_success

  run is_symlink
  assert_failure 1

  run is_symlink "file.txt"
  assert_failure 2
}

teardown () {
  rm -f file.txt link.txt
}
