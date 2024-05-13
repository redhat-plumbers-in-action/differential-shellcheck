# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "is_github_actions()" {
  source "${PROJECT_ROOT}/src/functions.sh"
  GITHUB_ACTIONS=

  run is_github_actions
  assert_failure 1

  GITHUB_ACTIONS="1"
  run is_github_actions
  assert_success
}

teardown () {
  export \
    GITHUB_ACTIONS=""
}
