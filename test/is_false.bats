# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "is_false() - good values" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local v1="false"
  local v2=0

  run is_false "${v1}"
  assert_success

  run is_false "${v2}"
  assert_success
}

@test "is_false() - bad values" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local v0=
  local v1="true"
  local v2=1

  run is_false "${v0}"
  assert_failure 1

  run is_false "${v1}"
  assert_failure 1

  run is_false "${v2}"
  assert_failure 1
}
