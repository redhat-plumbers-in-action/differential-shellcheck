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

@test "generate_SARIF() - arguments" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run generate_SARIF
  assert_failure 1

  run generate_SARIF "./test/fixtures/generate_SARIF/defects.log"
  assert_failure 1

  run generate_SARIF "./test/fixtures/generate_SARIF/defects.log" "test.sarif"
  assert_success
}

@test "generate_SARIF()" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run generate_SARIF "./test/fixtures/generate_SARIF/defects.log" "./test.sarif"
  assert_success
  assert_exists "./test.sarif"

  run cmp -s "test.sarif" "./test/fixtures/generate_SARIF/test.sarif"
  assert_success
}

teardown () {
  rm -f test.sarif
}
