#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later

CURRENT_DIR="$(dirname "$(readlink -f "$0")")"

# shellcheck source=functions.sh
. "${SCRIPT_DIR="${CURRENT_DIR}/"}functions.sh"

WORK_DIR="${WORK_DIR-../}"

declare \
  GITHUB_STEP_SUMMARY

# Make directory $GITHUB_WORKSPACE (/github/workspace) git-save
git config --global --add safe.directory "${GITHUB_WORKSPACE:-}"

# Chose correct BASE and HEAD commit for scan
pick_base_and_head_hash || exit 1

# Make sure we have correct BASE even when force-push was used
# source: https://stackoverflow.com/a/69893210/10221282
# !FIXME: It doesn't seems to work. Seems like action/checkout doesn't fetch all commits, so if we want to support force-pushes we probaly need to do it manually
# TODO: if force-push -> exit ???
# if ! git merge-base --is-ancestor "${BASE}" "${HEAD}" &>/dev/null && [[ "${INPUT_TRIGGERING_EVENT}" = "push" ]]; then
#   BASE=$(git merge-base "${GITHUB_REF}" "${HEAD}")
# fi

is_full_scan_demanded
FULL_SCAN=$?

if [[ ${FULL_SCAN} -eq 0 ]]; then
  git ls-tree -r --name-only -z "${GITHUB_REF_NAME-"main"}" > "${WORK_DIR}files.txt"

  all_scripts=()
  get_scripts_for_scanning "${WORK_DIR}files.txt" "all_scripts"
fi

if ! [[ ${FULL_SCAN} -eq 0 ]] || ! is_strict_check_on_push_demanded; then
  # https://github.com/actions/runner/issues/342
  # Get the names of files from range of commits (excluding deleted files)
  # BASE and HEAD are always set, it is checked inside pick_base_and_head_hash function
  git diff --name-only -z --diff-filter=db "${BASE}".."${HEAD}" > "${WORK_DIR}changed-files.txt"

  only_changed_scripts=()
  get_scripts_for_scanning "${WORK_DIR}changed-files.txt" "only_changed_scripts"
fi

echo -e "${VERSIONS_HEADING}"
show_versions

echo -e "${MAIN_HEADING}"

echo -e "::group::📜 ${WHITE}List of shell scripts for scanning${NOCOLOR}"
  echo "${all_scripts[@]:-${only_changed_scripts[@]}}"
echo "::endgroup::"
echo

# ------------ #
#  SHELLCHECK  #
# ------------ #

if [[ ${FULL_SCAN} -eq 0 ]]; then
  execute_shellcheck "${all_scripts[@]}" > "${WORK_DIR}full-shellcheck.err"
fi

exit_status=0

if ! is_strict_check_on_push_demanded; then
  execute_shellcheck "${only_changed_scripts[@]}" > "${WORK_DIR}head-shellcheck.err"

  # Checkout the base branch/commit
  git checkout --force --quiet -b ci_br_dest "${BASE}" || git checkout --force --quiet "${BASE}"

  execute_shellcheck "${only_changed_scripts[@]}" > "${WORK_DIR}base-shellcheck.err"

  get_fixes "${WORK_DIR}base-shellcheck.err" "${WORK_DIR}head-shellcheck.err"
  evaluate_and_print_fixes

  get_defects "${WORK_DIR}head-shellcheck.err" "${WORK_DIR}base-shellcheck.err"
else
  mv "${WORK_DIR}full-shellcheck.err" "${WORK_DIR}defects.log"
fi

echo

# Checkout the head branch/commit, it's required in order to correctly display defects in console
git checkout --force --quiet -

evaluate_and_print_defects
exit_status=$?

# Upload all defects when Full scan was requested
if [[ ${FULL_SCAN} -eq 0 ]]; then
  cp "${WORK_DIR}full-shellcheck.err" "${WORK_DIR}sarif-defects.log"
else
  cp "${WORK_DIR}defects.log" "${WORK_DIR}sarif-defects.log"
fi

shellcheck_version=$(get_shellcheck_version)

# GitHub requires an absolute path, so let's remove the './' prefix from it.
csgrep \
  --strip-path-prefix './' \
  --embed-context 4 \
  --mode=sarif \
  --set-scan-prop='tool:ShellCheck' \
  --set-scan-prop="tool-version:${shellcheck_version}" \
  --set-scan-prop='tool-url:https://www.shellcheck.net/wiki/' \
  "${WORK_DIR}sarif-defects.log" > output.sarif

# Produce report in HTML format
cshtml \
  "${WORK_DIR}sarif-defects.log" > output.xhtml

# shellcheck disable=SC2154
# GITHUB_OUTPUT is GitHub Actions environment variable
echo "sarif=output.sarif" >> "${GITHUB_OUTPUT}"
echo "html=output.xhtml" >> "${GITHUB_OUTPUT}"

# SARIF upload
if [[ -n "${INPUT_TOKEN}" ]]; then
  echo

  uploadSARIF
fi

summary >> "${GITHUB_STEP_SUMMARY}"

exit "${exit_status}"
