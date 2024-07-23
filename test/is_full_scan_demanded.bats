# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "is_full_scan_demanded() - trigger event = merge_group" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT="merge_group"

  run is_full_scan_demanded
  assert_failure 1
}

@test "is_full_scan_demanded() - trigger event = push" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT="push"

  run is_full_scan_demanded
  assert_success
}

@test "is_full_scan_demanded() - trigger event = pull_request" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT="pull_request"

  run is_full_scan_demanded
  assert_failure 1
}

@test "is_full_scan_demanded() - trigger event = manual" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT="manual"

  run is_full_scan_demanded
  assert_failure 1

  INPUT_DIFF_SCAN="false"
  run is_full_scan_demanded
  assert_success

  INPUT_DIFF_SCAN="true"
  run is_full_scan_demanded
  assert_failure 1
}

@test "is_full_scan_demanded() - trigger event = empty" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT=""

  run is_full_scan_demanded
  assert_failure 1
}

teardown () {
  export \
    INPUT_TRIGGERING_EVENT="" \
    INPUT_DIFF_SCAN=""
}
