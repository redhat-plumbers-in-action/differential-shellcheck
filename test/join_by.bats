# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "join_by() - ','" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run join_by "," "1.sh" "2.sh" "3.sh"
  assert_output "1.sh,2.sh,3.sh"

  run join_by ","
  assert_output ""

  run join_by "," "1.sh"
  assert_output "1.sh"
}

@test "join_by() - ' '" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run join_by " " "1.sh" "2.sh" "3.sh"
  assert_output "1.sh 2.sh 3.sh"

  run join_by " "
  assert_output ""

  run join_by " " "1.sh"
  assert_output "1.sh"
}

@test "join_by() - ''" {
  source "${PROJECT_ROOT}/src/functions.sh"

  run join_by "" "1.sh" "2.sh" "3.sh"
  assert_output "1.sh2.sh3.sh"

  run join_by ""
  assert_output ""

  run join_by "" "1.sh"
  assert_output "1.sh"
}
