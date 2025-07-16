# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "show_versions() - general" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run show_versions
  assert_success
  assert_output \
"ShellCheck: 0.10.0
csutils: 3.5.5"
}
