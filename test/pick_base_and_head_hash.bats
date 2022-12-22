# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "pick_base_and_head_hash() - trigger event = push" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT="push"

  run pick_base_and_head_hash
  assert_failure 2

  INPUT_PUSH_EVENT_BASE=""

  run pick_base_and_head_hash
  assert_failure 2

  INPUT_PUSH_EVENT_HEAD=""

  run pick_base_and_head_hash
  assert_failure 2

  INPUT_PUSH_EVENT_BASE="abcdef123456"
  INPUT_PUSH_EVENT_HEAD="ghijkl789012"

  run pick_base_and_head_hash
  # !FIXME: This should work ...
  # assert_equal "${BASE}" "${INPUT_PUSH_EVENT_BASE}"
  # assert_equal "${HEAD}" "${INPUT_PUSH_EVENT_HEAD}"
  assert_success
}

@test "pick_base_and_head_hash() - trigger event = pull_request" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT="pull_request"

  run pick_base_and_head_hash
  assert_failure 2

  INPUT_PULL_REQUEST_BASE=""

  run pick_base_and_head_hash
  assert_failure 2

  INPUT_PULL_REQUEST_HEAD=""

  run pick_base_and_head_hash
  assert_failure 2

  INPUT_PULL_REQUEST_BASE="abcdef123456"
  INPUT_PULL_REQUEST_HEAD="ghijkl789012"

  run pick_base_and_head_hash
  # !FIXME: This should work ...
  # assert_equal "${BASE}" "${INPUT_PULL_REQUEST_BASE}"
  # assert_equal "${HEAD}" "${INPUT_PULL_REQUEST_HEAD}"
  assert_success
}

@test "pick_base_and_head_hash() - trigger event = manual" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT="manual"

  run pick_base_and_head_hash
  assert_failure 2

  INPUT_BASE=""

  run pick_base_and_head_hash
  assert_failure 2

  INPUT_HEAD=""

  run pick_base_and_head_hash
  assert_failure 2

  INPUT_BASE="abcdef123456"
  INPUT_HEAD="ghijkl789012"

  run pick_base_and_head_hash
  # !FIXME: This should work ...
  # assert_equal "${BASE}" "${INPUT_BASE}"
  # assert_equal "${HEAD}" "${INPUT_HEAD}"
  assert_success
}

@test "pick_base_and_head_hash() - trigger event = empty" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT=""
  GITHUB_EVENT_NAME=""

  run pick_base_and_head_hash
  assert_failure 1
}

@test "pick_base_and_head_hash() - trigger event = UNSUPPORTED_VALUE" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT="UNSUPPORTED_VALUE"

  run pick_base_and_head_hash
  assert_failure 1
}

teardown () {
  export \
    INPUT_TRIGGERING_EVENT="" \
    GITHUB_EVENT_NAME="" \
    INPUT_PUSH_EVENT_BASE="" \
    INPUT_PUSH_EVENT_HEAD="" \
    INPUT_PULL_REQUEST_BASE="" \
    INPUT_PULL_REQUEST_HEAD="" \
    INPUT_BASE="" \
    INPUT_HEAD="" \
    BASE="" \
    HEAD=""
}
