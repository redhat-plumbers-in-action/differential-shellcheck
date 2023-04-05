# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "is_matched_by_exclude_path() - not matching exclude path" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_EXCLUDE_PATH=""

  run is_matched_by_exclude_path "1.sh"
  assert_failure 2

  INPUT_EXCLUDE_PATH="2.sh 3.sh"

  run is_matched_by_exclude_path "1.sh"
  assert_failure 2
}

@test "is_matched_by_exclude_path() - matching exclude path" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_EXCLUDE_PATH="**"

  run is_matched_by_exclude_path "1.sh"
  assert_success

  INPUT_EXCLUDE_PATH="3.sh 2.sh 1.sh"

  run is_matched_by_exclude_path "1.sh"
  assert_success

  INPUT_EXCLUDE_PATH="test/**"

  run is_matched_by_exclude_path "test/1.sh"
  assert_success
}

@test "is_matched_by_exclude_path() - matching exclude path - brace expansion" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_EXCLUDE_PATH="test/{**,*,}"

  run is_matched_by_exclude_path "test/1.sh"
  assert_success
  run is_matched_by_exclude_path "test/test/1.sh"
  assert_success
}

@test "is_matched_by_exclude_path() - bad number of arguments" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_EXCLUDE_PATH=""

  run is_matched_by_exclude_path
  assert_failure 1
}

teardown () {
  export \
    INPUT_EXCLUDE_PATH=""
}
