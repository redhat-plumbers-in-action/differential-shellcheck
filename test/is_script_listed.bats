setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "is_script_listed()" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run is_script_listed "1.sh" "1.sh" "2.sh" "3.sh"
  assert_success

  run is_script_listed
  assert_failure 1

  run is_script_listed "1.c"
  assert_failure 1

  run is_script_listed "1.c" "1.sh"
  assert_failure 2
}
