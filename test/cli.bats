# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'

  UNIT_TESTS="true"
  export UNIT_TESTS
}

# Helper to source parse_args and related functions
_source_cli () {
  # Source functions.sh for is_unit_tests, is_github_actions, etc.
  source "${PROJECT_ROOT}/src/functions.sh"

  # Source cli.sh functions without running main
  # We eval the file up to the main call
  eval "$(sed '/^main "\$@"/d' "${PROJECT_ROOT}/src/cli.sh")"
}

# --- --help ---

@test "cli --help exits 0 with usage text" {
  run "${PROJECT_ROOT}/src/cli.sh" --help
  assert_success
  assert_output --partial "Usage:"
  assert_output --partial "--base"
  assert_output --partial "--severity"
  assert_output --partial "--help"
}

# --- --version ---

@test "cli --version exits 0 with version" {
  run "${PROJECT_ROOT}/src/cli.sh" --version
  assert_success
  assert_output --partial "differential-shellcheck"
}

# --- --base and --head ---

@test "cli --base and --head set INPUT_BASE and INPUT_HEAD" {
  _source_cli

  parse_args --base abc123 --head def456
  assert_equal "${INPUT_BASE}" "abc123"
  assert_equal "${INPUT_HEAD}" "def456"
}

# --- --severity ---

@test "cli --severity sets INPUT_SEVERITY" {
  _source_cli

  parse_args --severity warning
  assert_equal "${INPUT_SEVERITY}" "warning"
}

@test "cli --severity accepts all valid values" {
  _source_cli

  for level in error warning info style; do
    parse_args --severity "${level}"
    assert_equal "${INPUT_SEVERITY}" "${level}"
  done
}

@test "cli --severity rejects invalid values" {
  _source_cli

  run parse_args --severity invalid
  assert_failure
}

# --- --full-scan ---

@test "cli --full-scan sets INPUT_DIFF_SCAN=false" {
  _source_cli

  parse_args --full-scan
  assert_equal "${INPUT_DIFF_SCAN}" "false"
  assert_equal "${CLI_MODE}" "full-scan"
}

# --- --external-sources / --no-external-sources ---

@test "cli --external-sources sets INPUT_EXTERNAL_SOURCES=true" {
  _source_cli

  parse_args --external-sources
  assert_equal "${INPUT_EXTERNAL_SOURCES}" "true"
}

@test "cli --no-external-sources sets INPUT_EXTERNAL_SOURCES=false" {
  _source_cli

  parse_args --no-external-sources
  assert_equal "${INPUT_EXTERNAL_SOURCES}" "false"
}

# --- --scan-directory ---

@test "cli --scan-directory sets INPUT_SCAN_DIRECTORY" {
  _source_cli

  parse_args --scan-directory "src/"
  assert_equal "${INPUT_SCAN_DIRECTORY}" "src/"
}

# --- --exclude-path ---

@test "cli --exclude-path accumulates multiple values" {
  _source_cli

  parse_args --exclude-path "test/**" --exclude-path "vendor/**"
  [[ "${INPUT_EXCLUDE_PATH}" == *"test/**"* ]]
  [[ "${INPUT_EXCLUDE_PATH}" == *"vendor/**"* ]]
}

# --- --include-path ---

@test "cli --include-path accumulates multiple values" {
  _source_cli

  parse_args --include-path "scripts/**" --include-path "bin/**"
  [[ "${INPUT_INCLUDE_PATH}" == *"scripts/**"* ]]
  [[ "${INPUT_INCLUDE_PATH}" == *"bin/**"* ]]
}

# --- --display-engine ---

@test "cli --display-engine sets INPUT_DISPLAY_ENGINE" {
  _source_cli

  parse_args --display-engine sarif-fmt
  assert_equal "${INPUT_DISPLAY_ENGINE}" "sarif-fmt"
}

# --- --verbose ---

@test "cli --verbose sets RUNNER_DEBUG=1" {
  _source_cli

  parse_args --verbose
  assert_equal "${RUNNER_DEBUG}" "1"
}

# --- INPUT_TRIGGERING_EVENT ---

@test "cli sets INPUT_TRIGGERING_EVENT=manual" {
  _source_cli

  parse_args --base abc --head def
  assert_equal "${INPUT_TRIGGERING_EVENT}" "manual"
}

# --- Positional FILE arguments ---

@test "cli positional FILE args set CLI_FILES and worktree-diff mode" {
  _source_cli

  parse_args -- script1.sh script2.sh
  assert_equal "${#CLI_FILES[@]}" "2"
  assert_equal "${CLI_FILES[0]}" "script1.sh"
  assert_equal "${CLI_FILES[1]}" "script2.sh"
  assert_equal "${CLI_MODE}" "worktree-diff"
}

@test "cli positional FILE args with --full-scan sets full-scan-files mode" {
  _source_cli

  parse_args --full-scan -- script1.sh script2.sh
  assert_equal "${#CLI_FILES[@]}" "2"
  assert_equal "${INPUT_DIFF_SCAN}" "false"
  assert_equal "${CLI_MODE}" "full-scan-files"
}

# --- Unknown options ---

@test "cli unknown option fails with error message" {
  _source_cli

  run parse_args --unknown-option
  assert_failure
}

# --- --upstream ---

@test "cli --upstream sets CLI_UPSTREAM" {
  _source_cli

  parse_args --upstream my-remote --base abc --head def
  assert_equal "${CLI_UPSTREAM}" "my-remote"
}

teardown () {
  export \
    INPUT_TRIGGERING_EVENT="" \
    INPUT_BASE="" \
    INPUT_HEAD="" \
    INPUT_SEVERITY="" \
    INPUT_EXTERNAL_SOURCES="" \
    INPUT_DISPLAY_ENGINE="" \
    INPUT_DIFF_SCAN="" \
    INPUT_STRICT_CHECK_ON_PUSH="" \
    INPUT_SCAN_DIRECTORY="" \
    INPUT_EXCLUDE_PATH="" \
    INPUT_INCLUDE_PATH="" \
    RUNNER_DEBUG="" \
    CLI_FILES="" \
    CLI_MODE="" \
    CLI_UPSTREAM="" \
    UNIT_TESTS=""
}
