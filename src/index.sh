#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later

CURRENT_DIR="$(dirname "$(readlink -f "$0")")"

# shellcheck source=functions.sh
. "${SCRIPT_DIR="${CURRENT_DIR}/"}functions.sh"
# shellcheck source=setup.sh
. "${SCRIPT_DIR=}setup.sh"

WORK_DIR="${WORK_DIR-../}"

declare \
  GITHUB_STEP_SUMMARY

export GROUP="::group::"
export ENDGROUP="::endgroup::"

# Make directory $GITHUB_WORKSPACE (/github/workspace) git-save
git config --global --add safe.directory "${GITHUB_WORKSPACE:-}"

# Chose correct BASE and HEAD commit for scan
pick_base_and_head_hash || exit 1

# Check if Base sha exists
if [[ "${BASE}" = "0000000000000000000000000000000000000000" ]]; then
  echo "::warning:: git: base SHA1 (${BASE}) doesn't exist. Make sure that the base branch is up-to-date."
  exit 0
fi

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
  if ! git diff --name-only -z --diff-filter=db "${BASE}".."${HEAD}" > "${WORK_DIR}changed-files.txt"; then
    echo "::warning:: Please check if the repository was cloned with \`fetch-depth: 0\`. Differential ShellCheck needs the entire history to work correctly."
     exit 1
  fi

  only_changed_scripts=()
  get_scripts_for_scanning "${WORK_DIR}changed-files.txt" "only_changed_scripts"
fi

echo -e "${VERSIONS_HEADING}"
show_versions

echo -e "${MAIN_HEADING}"

echo -e "${GROUP}📜 ${WHITE}List of shell scripts for scanning${NOCOLOR}"
  echo "${all_scripts[@]:-${only_changed_scripts[@]}}"
echo "${ENDGROUP}"
echo

# ------------ #
#  SHELLCHECK  #
# ------------ #

if [[ ${FULL_SCAN} -eq 0 ]]; then
  execute_shellcheck "${all_scripts[@]}" > "${WORK_DIR}full-shellcheck-raw.err"
  csgrep --mode=json --embed-context 4 "${WORK_DIR}full-shellcheck-raw.err" > "${WORK_DIR}full-shellcheck.err"

  echo "shellcheck-full=${WORK_DIR}full-shellcheck.err" >> "${GITHUB_OUTPUT}"
  is_debug \
    && echo "ShellCheck full scan:" \
    && cat "${WORK_DIR}full-shellcheck.err"
fi

exit_status=0

if ! is_strict_check_on_push_demanded; then
  execute_shellcheck "${only_changed_scripts[@]}" > "${WORK_DIR}head-shellcheck-raw.err"
  csgrep --mode=json --embed-context 4 "${WORK_DIR}head-shellcheck-raw.err" > "${WORK_DIR}head-shellcheck.err"

  echo "shellcheck-head=${WORK_DIR}head-shellcheck.err" >> "${GITHUB_OUTPUT}"
  is_debug \
    && echo "ShellCheck head scan:" \
    && cat "${WORK_DIR}head-shellcheck.err"

  # Save the current state of the working directory
  git stash push --quiet
  # Checkout the base branch/commit
  is_debug && echo "checkout HEAD"
  git checkout --force --quiet -b ci_br_dest "${BASE}" || git checkout --force --quiet "${BASE}" || echo "failed to checkout HEAD"

  execute_shellcheck "${only_changed_scripts[@]}" > "${WORK_DIR}base-shellcheck-raw.err"
  csgrep --mode=json --embed-context 4 "${WORK_DIR}base-shellcheck-raw.err" > "${WORK_DIR}base-shellcheck.err"

  get_fixes "${WORK_DIR}base-shellcheck.err" "${WORK_DIR}head-shellcheck.err"

  echo "shellcheck-base=${WORK_DIR}base-shellcheck.err" >> "${GITHUB_OUTPUT}"
  is_debug \
    && echo "ShellCheck base scan:" \
    && cat "${WORK_DIR}base-shellcheck.err"

  evaluate_and_print_fixes

  get_defects "${WORK_DIR}head-shellcheck.err" "${WORK_DIR}base-shellcheck.err"
else
  get_defects "${WORK_DIR}full-shellcheck.err" /dev/null  # csdiff --fixed swaps arguments
fi

echo

# Checkout the head branch/commit, it's required in order to correctly display defects in console
is_debug && echo "checkout HEAD"
git checkout --force --quiet - || echo "Failed to checkout HEAD"
# Restore the working directory to the state before the checkout
git stash pop --quiet

evaluate_and_print_defects
exit_status=$?

cp "${WORK_DIR}defects.log" "${WORK_DIR}sarif-defects.log"

generate_SARIF "${WORK_DIR}sarif-defects.log" "output.sarif"

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
