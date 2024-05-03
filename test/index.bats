# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "index.sh - source" {
  SCRIPT_DIR=""
  INPUT_TRIGGERING_EVENT="manual"
  INPUT_BASE="base"
  INPUT_HEAD="head"
  run . "$PROJECT_ROOT/src/index.sh"

  assert_success
}

teardown () {
  rm -f ../base-shellcheck.err ../changed-files.txt ../defects.log ../fixes.log ../head-shellcheck.err ./output.sarif ./output.xhtml

  export \
    SCRIPT_DIR="" \
    INPUT_TRIGGERING_EVENT="" \
    INPUT_BASE="" \
    INPUT_HEAD=""
}
