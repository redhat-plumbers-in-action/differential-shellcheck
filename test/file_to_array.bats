# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "file_to_array() - arguments" {
  source "${PROJECT_ROOT}/src/functions.sh"

  touch file.txt

  file_array=()
  run file_to_array "file.txt" "file_array"
  assert_failure 1
  assert_equal "${file_array[*]}" ""
}

# !FIXME - file_to_array() should succes when provided with empty file
@test "file_to_array() - empty file" {
  source "${PROJECT_ROOT}/src/functions.sh"

  touch file.txt

  file_array=()
  run file_to_array "file.txt" "file_array" 0
  # assert_success
  assert_equal "${file_array[*]}" ""
}

@test "file_to_array() - in-line comments" {
  source "${PROJECT_ROOT}/src/functions.sh"

  echo -e "\
# comment
#comment
Something1\t # comment
# comment
\rSomething2\r #comment
Something3" > file.txt

  local file_array=()
  file_to_array "file.txt" "file_array" 1
  assert_equal "${file_array[*]}" "Something1 Something2 Something3"
}

@test "file_to_array() - no in-line comments" {
  source "${PROJECT_ROOT}/src/functions.sh"

  echo -e "\
# comment
#comment
Something1\t
# comment
\rSomething2\r 
Something3
Something 4 \r
\r Something5&Something6 conf \r" > file.txt

  local file_array=()
  file_to_array "file.txt" "file_array" 0
  assert_equal "${file_array[*]}" "Something1 Something2 Something3 Something 4 Something5&Something6 conf"
}

teardown () {
  rm -f file.txt
}
