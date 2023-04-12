# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "is_matched_by_path() - not matching" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_EXCLUDE_PATH=""

  run is_matched_by_path "1.sh" "${INPUT_EXCLUDE_PATH}"
  assert_failure 2

  INPUT_EXCLUDE_PATH="2.sh 3.sh"

  run is_matched_by_path "1.sh" "${INPUT_EXCLUDE_PATH}"
  assert_failure 2
}

@test "is_matched_by_path() - matching" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_EXCLUDE_PATH="**"

  run is_matched_by_path "1.sh" "${INPUT_EXCLUDE_PATH}"
  assert_success

  INPUT_EXCLUDE_PATH="3.sh 2.sh 1.sh"

  run is_matched_by_path "1.sh" "${INPUT_EXCLUDE_PATH}"
  assert_success

  INPUT_EXCLUDE_PATH="test/**"

  run is_matched_by_path "test/1.sh" "${INPUT_EXCLUDE_PATH}"
  assert_success
}

@test "is_matched_by_path() - matching - brace expansion" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_EXCLUDE_PATH="test/{**,*,}"

  run is_matched_by_path "test/1.sh" "${INPUT_EXCLUDE_PATH}"
  assert_success
  run is_matched_by_path "test/test/1.sh" "${INPUT_EXCLUDE_PATH}"
  assert_success
  
  INPUT_EXCLUDE_PATH="fixture/**.fixture"

  run is_matched_by_path "fixture/1.fixture" "${INPUT_EXCLUDE_PATH}"
  assert_success
  run is_matched_by_path "fixture/test/1.fixture" "${INPUT_EXCLUDE_PATH}"
  assert_success
}

@test "is_matched_by_path() - matching - multiline input" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_EXCLUDE_PATH="test/{**,*,}
test/**
1.sh"

  run is_matched_by_path "test/1.sh" "${INPUT_EXCLUDE_PATH}"
  assert_success
  run is_matched_by_path "1.sh" "${INPUT_EXCLUDE_PATH}"
  assert_success
}

@test "is_matched_by_path() - bad number of arguments" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_EXCLUDE_PATH=""

  run is_matched_by_path
  assert_failure 1
  run is_matched_by_path "${INPUT_EXCLUDE_PATH}"
  assert_failure 1
}

teardown () {
  export \
    INPUT_EXCLUDE_PATH=""
}
