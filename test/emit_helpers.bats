# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

# --- emit_output ---

@test "emit_output() - GitHub Actions mode" {
  source "${PROJECT_ROOT}/src/functions.sh"

  GITHUB_ACTIONS="1"
  local tmpfile
  tmpfile=$(mktemp)
  GITHUB_OUTPUT="${tmpfile}"

  run emit_output "sarif" "output.sarif"
  assert_success

  run cat "${tmpfile}"
  assert_output "sarif=output.sarif"

  rm -f "${tmpfile}"
}

@test "emit_output() - CLI mode (no-op)" {
  source "${PROJECT_ROOT}/src/functions.sh"

  GITHUB_ACTIONS=""

  run emit_output "sarif" "output.sarif"
  assert_success
  assert_output ""
}

@test "emit_output() - missing arguments" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run emit_output
  assert_failure 1

  run emit_output "key"
  assert_failure 1
}

# --- emit_warning ---

@test "emit_warning() - GitHub Actions mode" {
  source "${PROJECT_ROOT}/src/functions.sh"

  GITHUB_ACTIONS="1"

  run emit_warning "something went wrong"
  assert_success
  assert_output "::warning:: something went wrong"
}

@test "emit_warning() - CLI mode" {
  source "${PROJECT_ROOT}/src/functions.sh"

  GITHUB_ACTIONS=""

  local output
  output=$(emit_warning "something went wrong" 2>&1)
  [[ "${output}" == "WARNING: something went wrong" ]]
}

@test "emit_warning() - missing arguments" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run emit_warning
  assert_failure 1
}

# --- emit_group_start ---

@test "emit_group_start() - GitHub Actions mode" {
  source "${PROJECT_ROOT}/src/functions.sh"

  GITHUB_ACTIONS="1"

  run emit_group_start "My Group Title"
  assert_success
  assert_output "::group::My Group Title"
}

@test "emit_group_start() - CLI mode" {
  source "${PROJECT_ROOT}/src/functions.sh"

  GITHUB_ACTIONS=""

  run emit_group_start "My Group Title"
  assert_success
  assert_output "--- My Group Title ---"
}

@test "emit_group_start() - missing arguments" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run emit_group_start
  assert_failure 1
}

# --- emit_group_end ---

@test "emit_group_end() - GitHub Actions mode" {
  source "${PROJECT_ROOT}/src/functions.sh"

  GITHUB_ACTIONS="1"

  run emit_group_end
  assert_success
  assert_output "::endgroup::"
}

@test "emit_group_end() - CLI mode" {
  source "${PROJECT_ROOT}/src/functions.sh"

  GITHUB_ACTIONS=""

  run emit_group_end
  assert_success
  assert_output ""
}

# --- emit_summary ---

@test "emit_summary() - GitHub Actions mode" {
  source "${PROJECT_ROOT}/src/functions.sh"

  GITHUB_ACTIONS="1"
  local tmpfile
  tmpfile=$(mktemp)
  GITHUB_STEP_SUMMARY="${tmpfile}"

  run emit_summary "Summary text here"
  assert_success

  run cat "${tmpfile}"
  assert_output "Summary text here"

  rm -f "${tmpfile}"
}

@test "emit_summary() - CLI mode (prints to stdout)" {
  source "${PROJECT_ROOT}/src/functions.sh"

  GITHUB_ACTIONS=""

  run emit_summary "Summary text here"
  assert_success
  assert_output "Summary text here"
}

@test "emit_summary() - missing arguments" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run emit_summary
  assert_failure 1
}

teardown () {
  export \
    GITHUB_ACTIONS="" \
    GITHUB_OUTPUT="" \
    GITHUB_STEP_SUMMARY=""
}
