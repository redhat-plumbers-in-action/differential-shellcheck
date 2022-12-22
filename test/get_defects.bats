# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-file/load'
}

@test "get_defects()" {
  source "${PROJECT_ROOT}/src/validation.sh"

  run get_defects
  assert_failure 1

  run get_defects "arg1"
  assert_failure 1

  run get_defects "./test/fixtures/get_defects/head.err" "./test/fixtures/get_defects/base.err"
  assert_success
  assert_exists ../defects.log

  run cmp -s "../defects.log" "./test/fixtures/get_defects/defects.log"
  assert_success
}

teardown () {
  rm -f ../defects.log
}
