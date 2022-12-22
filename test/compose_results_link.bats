# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "compose_results_link() - trigger event = push" {
  source "${PROJECT_ROOT}/src/summary.sh"

  INPUT_TRIGGERING_EVENT="push"
  GITHUB_REPOSITORY="test-user/test-repo"
  GITHUB_REF_NAME="test-branch"
  SCANNING_TOOL="not-shellcheck"
  GITHUB_REF="refs/heads/${GITHUB_REF_NAME}"

  run compose_results_link "Result Link"
  assert_success
  assert_output "[Result Link](https://github.com/${GITHUB_REPOSITORY}/security/code-scanning?query=tool%3A${SCANNING_TOOL}+branch%3A${GITHUB_REF_NAME}+is%3Aopen)"

  run compose_results_link
  assert_failure 1
}

@test "compose_results_link() - trigger event = pull_request" {
  source "${PROJECT_ROOT}/src/summary.sh"

  INPUT_TRIGGERING_EVENT="pull_request"
  GITHUB_REPOSITORY="test-user/test-repo"
  PR_NUMBER=123
  SCANNING_TOOL="not-shellcheck"
  GITHUB_REF="refs/pull/${PR_NUMBER}/merge"

  run compose_results_link "Result Link"
  assert_success
  assert_output "[Result Link](https://github.com/${GITHUB_REPOSITORY}/security/code-scanning?query=pr%3A${PR_NUMBER}+tool%3A${SCANNING_TOOL}+is%3Aopen)"

  run compose_results_link
  assert_failure 1
}

@test "compose_results_link() - trigger event = manual" {
  source "${PROJECT_ROOT}/src/summary.sh"

  INPUT_TRIGGERING_EVENT="manual"
  SCANNING_TOOL="not-shellcheck"

  run compose_results_link "Result Link"
  assert_success
  assert_output "Result Link"

  run compose_results_link
  assert_failure 1
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
