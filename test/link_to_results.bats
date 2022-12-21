# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "link_to_results () - trigger event = push" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT="push"
  GITHUB_REPOSITORY="test-user/test-repo"
  GITHUB_REF_NAME="test-branch"
  SCANNING_TOOL="not-shellcheck"
  GITHUB_REF="refs/heads/${GITHUB_REF_NAME}"

  run link_to_results
  assert_success
  assert_output "https://github.com/${GITHUB_REPOSITORY}/security/code-scanning?query=tool%3A${SCANNING_TOOL}+branch%3A${GITHUB_REF_NAME}"
}

@test "link_to_results () - trigger event = pull_request" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT="pull_request"
  GITHUB_REPOSITORY="test-user/test-repo"
  PR_NUMBER=123
  SCANNING_TOOL="not-shellcheck"
  GITHUB_REF="refs/pull/${PR_NUMBER}/merge"

  run link_to_results
  assert_success
  assert_output "https://github.com/${GITHUB_REPOSITORY}/security/code-scanning?query=pr%3A${PR_NUMBER}+tool%3A${SCANNING_TOOL}"
}

@test "link_to_results () - trigger event = manual" {
  source "${PROJECT_ROOT}/src/functions.sh"

  INPUT_TRIGGERING_EVENT="manual"
  SCANNING_TOOL="not-shellcheck"

  run link_to_results
  assert_success
  assert_output ""
}

teardown () {
  export \
    INPUT_TRIGGERING_EVENT="" \
    GITHUB_REPOSITORY="" \
    GITHUB_REF_NAME="" \
    GITHUB_REF="" \
    PR_NUMBER="" \
    SCANNING_TOOL=""
}
