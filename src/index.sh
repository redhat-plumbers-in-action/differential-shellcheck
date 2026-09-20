#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later

CURRENT_DIR="$(dirname "$(readlink -f "$0")")"

# shellcheck source=functions.sh
. "${SCRIPT_DIR="${CURRENT_DIR}/"}functions.sh"
# shellcheck source=setup.sh
. "${SCRIPT_DIR=}setup.sh"

WORK_DIR="${WORK_DIR-../}"

# CLI_FILES may be set by the CLI wrapper (cli.sh) to provide explicit file list
if [[ -z "${CLI_FILES+x}" ]]; then
  CLI_FILES=()
fi

# Make directory $GITHUB_WORKSPACE (/github/workspace) git-save
if is_github_actions; then
  git config --global --add safe.directory "${GITHUB_WORKSPACE:-}"
fi

# Chose correct BASE and HEAD commit for scan
pick_base_and_head_hash || exit 1

# Check if Base sha exists
if [[ "${BASE}" = "0000000000000000000000000000000000000000" ]]; then
  emit_warning "git: base SHA1 (${BASE}) doesn't exist. Make sure that the base branch is up-to-date."
  exit 0
fi

# Make sure we have correct BASE even when force-push was used
# source: https://stackoverflow.com/a/69893210/10221282
# !FIXME: It doesn't seems to work. Seems like action/checkout doesn't fetch all commits, so if we want to support force-pushes we probably need to do it manually
# TODO: if force-push -> exit ???
# if ! git merge-base --is-ancestor "${BASE}" "${HEAD}" &>/dev/null && [[ "${INPUT_TRIGGERING_EVENT}" = "push" ]]; then
#   BASE=$(git merge-base "${GITHUB_REF}" "${HEAD}")
# fi

is_full_scan_demanded
FULL_SCAN=$?

if [[ ${FULL_SCAN} -eq 0 ]]; then
  if [[ ${#CLI_FILES[@]} -gt 0 ]]; then
    all_scripts=("${CLI_FILES[@]}")
  else
    git ls-tree -r --name-only -z "${GITHUB_REF_NAME:-HEAD}" > "${WORK_DIR}files.txt"

    all_scripts=()
    get_scripts_for_scanning "${WORK_DIR}files.txt" "all_scripts"
  fi
fi

if ! [[ ${FULL_SCAN} -eq 0 ]] || ! is_strict_check_on_push_demanded; then
  if [[ ${#CLI_FILES[@]} -gt 0 ]]; then
    only_changed_scripts=("${CLI_FILES[@]}")
  else
    # https://github.com/actions/runner/issues/342
    # Get the names of files from range of commits (excluding deleted files)
    # BASE and HEAD are always set, it is checked inside pick_base_and_head_hash function
    if ! git diff --name-only -z --diff-filter=db "${BASE}".."${HEAD}" > "${WORK_DIR}changed-files.txt"; then
      emit_warning "Please check if the repository was cloned with \`fetch-depth: 0\`. Differential ShellCheck needs the entire history to work correctly."
      exit 1
    fi

    only_changed_scripts=()
    get_scripts_for_scanning "${WORK_DIR}changed-files.txt" "only_changed_scripts"
  fi
fi

echo -e "${VERSIONS_HEADING}"
show_versions

echo -e "${MAIN_HEADING}"

emit_group_start "📜 ${WHITE}List of shell scripts for scanning${NOCOLOR}"
  echo "${all_scripts[@]:-${only_changed_scripts[@]}}"
emit_group_end
echo

# ------------ #
#  SHELLCHECK  #
# ------------ #

if [[ ${FULL_SCAN} -eq 0 ]]; then
  execute_shellcheck "${all_scripts[@]}" > "${WORK_DIR}full-shellcheck-raw.err"
  csgrep --mode=json --embed-context 4 "${WORK_DIR}full-shellcheck-raw.err" > "${WORK_DIR}full-shellcheck.err"

  emit_output "shellcheck-full" "${WORK_DIR}full-shellcheck.err"
  is_debug \
    && echo "ShellCheck full scan:" \
    && cat "${WORK_DIR}full-shellcheck.err"
fi

exit_status=0

if ! is_strict_check_on_push_demanded; then
  execute_shellcheck "${only_changed_scripts[@]}" > "${WORK_DIR}head-shellcheck-raw.err"
  csgrep --mode=json --embed-context 4 "${WORK_DIR}head-shellcheck-raw.err" > "${WORK_DIR}head-shellcheck.err"

  emit_output "shellcheck-head" "${WORK_DIR}head-shellcheck.err"
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

  emit_output "shellcheck-base" "${WORK_DIR}base-shellcheck.err"
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

emit_output "sarif" "output.sarif"
emit_output "html" "output.xhtml"

# SARIF upload
if is_github_actions && [[ -n "${INPUT_TOKEN:-}" ]]; then
  echo

  uploadSARIF
fi

summary_text="$(summary)"
emit_summary "${summary_text}"

exit "${exit_status}"
