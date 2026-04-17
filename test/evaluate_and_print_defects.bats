# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "evaluate_and_print_defects() - some defects" {
  source "${PROJECT_ROOT}/src/functions.sh"
  source "${PROJECT_ROOT}/src/validation.sh"

  GITHUB_ACTIONS="1"
  INPUT_SEVERITY="style"
  cp ./test/fixtures/evaluate_and_print_defects/defects.log ../defects.log

  run evaluate_and_print_defects
  assert_failure 1
  assert_output --partial "\
::group::📊 Statistics of defects
Error: 0
Warning: 2
Style or Note: 0
::endgroup::"
  assert_line --partial "innocent-script.sh:7: warning[SC2034]: UNUSED_VAR2 appears unused. Verify use (or export if used externally)."
  assert_line --partial 'innocent-script.sh:11: warning[SC2115]: Use "${var:?}" to ensure this never expands to / .'
}

@test "evaluate_and_print_defects() - no defects" {
  source "${PROJECT_ROOT}/src/functions.sh"
  source "${PROJECT_ROOT}/src/validation.sh"

  echo -e \
'{
    "defects": []
}' > ../defects.log

  run evaluate_and_print_defects
  assert_success
  assert_output "🥳 No defects added. Yay!"
}

teardown () {
  rm -f ../defects.log
  export GITHUB_ACTIONS=""
}
