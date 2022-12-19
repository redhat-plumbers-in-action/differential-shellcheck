#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

. "${SCRIPT_DIR}/functions.sh"

declare \
  GITHUB_ENV \
  GITHUB_STEP_SUMMARY

# ------------ #
#  FILE PATHS  #
# ------------ #

# Make directory $GITHUB_WORKSPACE (/github/workspace) git-save
git config --global --add safe.directory "${GITHUB_WORKSPACE?"❓ Variable GITHUB_WORKSPACE doesn't exist"}"

# Chose correct BASE and HEAD commit for scan
pick_base_and_head_hash || exit 1

# Make sure we have correct BASE even when force-push was used
# source: https://stackoverflow.com/a/69893210/10221282
# !FIXME: It doesn't seems to work. Seems like action/checkout doesn't fetch all commits, so if we want to support force-pushes we probaly need to do it manually
# if ! git merge-base --is-ancestor "${BASE}" "${HEAD}" &>/dev/null && [[ "${INPUT_TRIGGERING_EVENT}" = "push" ]]; then
#   BASE=$(git merge-base "${GITHUB_REF}" "${HEAD}")
# fi

# https://github.com/actions/runner/issues/342
# Get the names of files from range of commits (excluding deleted files)
git diff --name-only --diff-filter=db "${BASE}".."${HEAD}" > ../pr-changes.txt

# Find modified shell scripts
list_of_changes=()
file_to_array "../pr-changes.txt" "list_of_changes" 0
list_of_scripts=()
[[ -f "${INPUT_SHELL_SCRIPTS:-}" ]] && file_to_array "${INPUT_SHELL_SCRIPTS}" "list_of_scripts" 1

# Create a list of scripts for testing
list_of_changed_scripts=()
for file in "${list_of_changes[@]}"; do
  is_symlink "${file}" && continue
  is_script_listed "${file}" "${list_of_scripts[@]}" && list_of_changed_scripts+=("./${file}") && continue
  is_shell_extension "${file}" && list_of_changed_scripts+=("./${file}") && continue
  has_shebang "${file}" && list_of_changed_scripts+=("./${file}")
done

# Expose list_of_changed_scripts[*] for use within the GA workflow
echo "LIST_OF_SCRIPTS=${list_of_changed_scripts[*]}" >> "${GITHUB_ENV}"

# Get a list of exceptions
list_of_exceptions=()
[[ -f "${INPUT_IGNORED_CODES:-}" ]] && file_to_array "${INPUT_IGNORED_CODES}" "list_of_exceptions" 1
string_of_exceptions=$(join_by , "${list_of_exceptions[@]}")

echo -e "${VERSIONS_HEADING}"
show_versions

echo -e "${MAIN_HEADING}"

if is_debug; then
  echo -e "📜 ${WHITE}Changed shell scripts${NOCOLOR}"
  echo "${list_of_changed_scripts[@]}"
  echo
  echo -e "👌 ${WHITE}List of ShellCheck exceptions${NOCOLOR}"
  echo "${string_of_exceptions}"
  echo
fi

# ------------ #
#  SHELLCHECK  #
# ------------ #

# The sed part ensures that cstools will recognize the output as being produced
# by ShellCheck and not GCC.
execute_shellcheck > ../pr-br-shellcheck.err

# Check the destination branch
# shellcheck disable=SC2086
git checkout --force -q -b ci_br_dest ${BASE}

execute_shellcheck > ../dest-br-shellcheck.err

# ------------ #
#  VALIDATION  #
# ------------ #

exit_status=0

# Check output for Fixes
csdiff --fixed "../dest-br-shellcheck.err" "../pr-br-shellcheck.err" > ../fixes.log

if [[ -s ../fixes.log ]]; then
  echo -e "✅ ${GREEN}Fixed defects${NOCOLOR}"
  csgrep ../fixes.log
else
  echo -e "ℹ️ ${YELLOW}No Fixes!${NOCOLOR}"
fi

echo

# Check output for added defects
csdiff --fixed "../pr-br-shellcheck.err" "../dest-br-shellcheck.err" > ../defects.log

if [[ -s ../defects.log ]]; then
  echo -e "✋ ${YELLOW}Added defects, NEEDS INSPECTION${NOCOLOR}"
  csgrep ../defects.log
  exit_status=1
else
  echo -e "🥳 ${GREEN}No defects added. Yay!${NOCOLOR}"
  exit_status=0
fi

# SARIF upload
if [[ -n "${INPUT_TOKEN}" ]]; then
  echo

  # GitHub requires an absolute path, so let's remove the './' prefix from it.
  # TODO: Don't hardcode ShellCheck version
  csgrep \
    --strip-path-prefix './' \
    --mode=sarif \
    --set-scan-prop='tool:ShellCheck' \
    --set-scan-prop='tool-version:0.8.0' \
    --set-scan-prop='tool-url:https://www.shellcheck.net/wiki/' \
    '../defects.log' >> output.sarif && uploadSARIF
fi

summary >> "${GITHUB_STEP_SUMMARY}"

exit "${exit_status}"
