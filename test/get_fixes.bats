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

@test "get_fixes()" {
  source "${PROJECT_ROOT}/src/validation.sh"

  run get_fixes
  assert_failure 1

  run get_fixes "arg1"
  assert_failure 1

  run get_fixes "./test/fixtures/get_fixes/base.err" "./test/fixtures/get_fixes/head.err"
  assert_success
  assert_exists ../fixes.log

  run cmp -s "../fixes.log" "./test/fixtures/get_fixes/fixes.log"
  assert_success
}

teardown () {
  rm -f ../fixes.log
}
