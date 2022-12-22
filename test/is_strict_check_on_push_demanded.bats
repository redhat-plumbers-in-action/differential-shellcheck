# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "is_strict_check_on_push_demanded() - trigger event = push" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT="push"
  INPUT_STRICT_CHECK_ON_PUSH=""

  run is_strict_check_on_push_demanded
  assert_failure 2

  INPUT_TRIGGERING_EVENT="push"
  INPUT_STRICT_CHECK_ON_PUSH="false"

  run is_strict_check_on_push_demanded
  assert_failure 2

  INPUT_TRIGGERING_EVENT="push"
  INPUT_STRICT_CHECK_ON_PUSH="true"

  run is_strict_check_on_push_demanded
  assert_success
}

@test "is_strict_check_on_push_demanded() - trigger event = pull_request" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT="pull_request"
  INPUT_STRICT_CHECK_ON_PUSH=""

  run is_strict_check_on_push_demanded
  assert_failure 1

  INPUT_TRIGGERING_EVENT="pull_request"
  INPUT_STRICT_CHECK_ON_PUSH="false"

  run is_strict_check_on_push_demanded
  assert_failure 1

  INPUT_TRIGGERING_EVENT="pull_request"
  INPUT_STRICT_CHECK_ON_PUSH="true"

  run is_strict_check_on_push_demanded
  assert_failure 1
}

@test "is_strict_check_on_push_demanded() - trigger event = empty" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT=""

  run is_strict_check_on_push_demanded
  assert_failure 1
}

teardown () {
  export \
    INPUT_TRIGGERING_EVENT="" \
    INPUT_STRICT_CHECK_ON_PUSH=""
}
