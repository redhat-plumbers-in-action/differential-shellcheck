# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "summary_defect_statistics() - all N/A" {
  source "${PROJECT_ROOT}/src/summary.sh"

  run summary_defect_statistics
  assert_success
  assert_output \
"#### New defects statistics

|          | 👕 Style / 🗒️ Note      | ⚠️ Warning                 | 🛑 Error                 |
|:--------:|:-----------------------:|:--------------------------:|:------------------------:|
| 🔢 Count | **N/A** | **N/A** | **N/A** |"
}

@test "summary_defect_statistics() - general" {
  source "${PROJECT_ROOT}/src/summary.sh"

  stat_warning=10
  stat_error=0

  run summary_defect_statistics
  assert_success
  assert_output \
"#### New defects statistics

|          | 👕 Style / 🗒️ Note      | ⚠️ Warning                 | 🛑 Error                 |
|:--------:|:-----------------------:|:--------------------------:|:------------------------:|
| 🔢 Count | **N/A** | **10** | **0** |"
}


