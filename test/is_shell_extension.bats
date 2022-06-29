setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "is_shell_extension() - .sh" {
  source "$PROJECT_ROOT/src/functions.sh"

  run is_shell_extension "1.sh"
  assert_success

  run is_shell_extension
  assert_failure 1

  run is_shell_extension "blah"
  assert_failure 2
}

@test "is_shell_extension() - .bash" {
  source "$PROJECT_ROOT/src/functions.sh"

  run is_shell_extension "1.bash"
  assert_success

  run is_shell_extension
  assert_failure 1

  run is_shell_extension "blah"
  assert_failure 2
}
