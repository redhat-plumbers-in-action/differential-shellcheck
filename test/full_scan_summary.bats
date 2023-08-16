# SPDX-License-Identifier: GPL-3.0-or-later

setup_file () {
  load 'test_helper/common-setup'
  _common_setup
}

setup () {
  load 'test_helper/bats-assert/load'
  load 'test_helper/bats-support/load'
}

@test "full_scan_summary() - general" {
  source "${PROJECT_ROOT}/src/summary.sh"

  export all_scripts=("1.sh" "\$2.sh" "3 .sh")
  INPUT_TRIGGERING_EVENT=""

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
                    "file_name": "innocent-script.sh",
                    "line": 7,
                    "event": "warning[SC2034]",
                    "message": "UNUSED_VAR2 appears unused. Verify use (or export if used externally).",
                    "verbosity_level": 0
                }
            ]
        }, {}, {}
    ]
}' > ../defects.log

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
                    "file_name": "innocent-script.sh",
                    "line": 6,
                    "event": "warning[SC2034]",
                    "message": "UNUSED_VAR appears unused. Verify use (or export if used externally).",
                    "verbosity_level": 0
                }
            ]
        }
    ]
}' > ../fixes.log

  run full_scan_summary
  assert_success
  assert_output \
"Number of scripts: \`3\`

Defects: **3**"
}

@test "full_scan_summary() - no fixes or defects" {
  source "${PROJECT_ROOT}/src/summary.sh"

  export all_scripts=("1.sh" "\$2.sh" "3 .sh")
  INPUT_TRIGGERING_EVENT=""

  touch ../defects.log ../fixes.log

  run full_scan_summary
  assert_success
  assert_output \
"Number of scripts: \`3\`

Defects: **0**"
}

@test "full_scan_summary() - no changed shell scripts" {
  source "${PROJECT_ROOT}/src/summary.sh"

  export all_scripts=()
  INPUT_TRIGGERING_EVENT=""

  touch ../defects.log ../fixes.log

  run full_scan_summary
  assert_success
  assert_output \
"Number of scripts: \`0\`

Defects: **0**"
}

teardown () {
  rm -f ../defects.log ../fixes.log

  export \
    all_scripts="" \
    INPUT_TRIGGERING_EVENT=""
}
