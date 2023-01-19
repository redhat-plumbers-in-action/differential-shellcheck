# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "clean_array() - arguments" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local cleaned_array=()
  run clean_array
  assert_failure 1

  run clean_array "cleaned_array"
  assert_failure 1

  run clean_array "cleaned_array" "Something"
  assert_success
}

@test "clean_array()" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local cleaned_array=()
  local el1=$(echo -e "Something1 \n")
  local el2=$(echo -e "Something2\r ")
  local el3=$(echo -e "\n Something3 \n")
  
  clean_array "cleaned_array" "$el1" "$el2" "$el3"
  assert_equal "\"${cleaned_array[0]}\"" "\"Something1\""
  assert_equal "\"${cleaned_array[1]}\"" "\"Something2\""
  assert_equal "\"${cleaned_array[2]}\"" "\"Something3\""
}

@test "clean_array() - special characters" {
  source "${PROJECT_ROOT}/src/functions.sh"

  local cleaned_array=()
  local el1=$(echo -e "Something1 conf\n")
  local el2=$(echo -e "Something2 conf\r ")
  local el3=$(echo -e "\n Something3 conf\n")
  local el4=$(echo -e "\n Something4\&Something4 conf \n")
  
  clean_array "cleaned_array" "$el1" "$el2" "$el3" "$el4"
  assert_equal "\"${cleaned_array[0]}\"" "\"Something1 conf\""
  assert_equal "\"${cleaned_array[1]}\"" "\"Something2 conf\""
  assert_equal "\"${cleaned_array[2]}\"" "\"Something3 conf\""
  assert_equal "\"${cleaned_array[3]}\"" "\"Something4\&Something4 conf\""
}
