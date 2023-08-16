# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "get_number_of() - arguments" {
  source "${PROJECT_ROOT}/src/summary.sh"

  run get_number_of
  assert_failure 1
}

@test "get_number_of() - defects" {
  source "${PROJECT_ROOT}/src/summary.sh"

  echo -e \
'{
    "defects": [
        {
            "checker": "SHELLCHECK_WARNING",
            "language": "shell",
            "tool": "shellcheck",
            "key_event_idx": 0,
            "events": [
                {
                    "file_name": "tests/test-lib.sh",
                    "line": 1,
                    "column": 1,
                    "event": "error[SC2148]",
                    "message": "Tips depend on target shell and yours is unknown. Add a shebang or a shell directive.",
                    "verbosity_level": 0
                }
            ]
        },
        {},
        {}
    ]
}' > ../defects.log

  run get_number_of "defects"
  assert_success
  assert_output "3"
}

@test "get_number_of() - fixes" {
  source "${PROJECT_ROOT}/src/summary.sh"

  echo -e \
'{
    "defects": [
        {
            "checker": "SHELLCHECK_WARNING",
            "language": "shell",
            "tool": "shellcheck",
            "key_event_idx": 0,
            "events": [
                {
                    "file_name": "tests/test-lib.sh",
                    "line": 1,
                    "column": 1,
                    "event": "error[SC2148]",
                    "message": "Tips depend on target shell and yours is unknown. Add a shebang or a shell directive.",
                    "verbosity_level": 0
                }
            ]
        }
    ]
}' > ../fixes.log

  run get_number_of "fixes"
  assert_success
  assert_output "1"
}

teardown () {
  rm -f ../fixes.log ../defects.log
}
