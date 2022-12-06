# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "is_debug() - RUNNER_DEBUG=" {
  source "${PROJECT_ROOT}/src/functions.sh"

  RUNNER_DEBUG=

  run is_debug
  assert_failure 1
}

@test "is_shell_extension() - RUNNER_DEBUG=1" {
  source "${PROJECT_ROOT}/src/functions.sh"

  RUNNER_DEBUG=1

  run is_debug
  assert_success
}

teardown () {
  export RUNNER_DEBUG=
}
