#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

. $SCRIPT_DIR/functions.sh

# ------------ #
#  FILE PATHS  #
# ------------ #

# Make directory /github/workspace git-save
git config --global --add safe.directory /github/workspace

# https://github.com/actions/runner/issues/342
# get names of files from PR (excluding deleted files)
git diff --name-only --diff-filter=db "$INPUT_BASE".."$INPUT_HEAD" > ../pr-changes.txt

# Find modified shell scripts
list_of_changes=()
file_to_array "../pr-changes.txt" "list_of_changes" 0
list_of_scripts=()
[ -f "$INPUT_SHELL_SCRIPTS" ] && file_to_array "$INPUT_SHELL_SCRIPTS" "list_of_scripts" 1

# Create list of scripts for testing
list_of_changed_scripts=()
for file in "${list_of_changes[@]}"; do
  is_script_listed "$file" "${list_of_scripts[@]}" && list_of_changed_scripts+=("./${file}") && continue
  is_shell_extension "$file" && list_of_changed_scripts+=("./${file}") && continue
  has_shebang "$file" && list_of_changed_scripts+=("./${file}")
done

# Expose list_of_changed_scripts[*] for use inside GA workflow
echo "LIST_OF_SCRIPTS=${list_of_changed_scripts[*]}" >> "$GITHUB_ENV"

# Get list of exceptions
list_of_exceptions=()
[ -f "$INPUT_IGNORED_CODES" ] && file_to_array "$INPUT_IGNORED_CODES" "list_of_exceptions" 1
string_of_exceptions=$(join_by , "${list_of_exceptions[@]}")

echo -e "${MAIN_HEADING}"

if is_debug ; then 
  echo -e "📜 ${WHITE}Changed shell scripts${NOCOLOR}"
  echo "${list_of_changed_scripts[@]}"
  echo
  echo -e "👌 ${WHITE}List of shellcheck exceptions${NOCOLOR}"
  echo "${string_of_exceptions}"
  echo
fi

# ------------ #
#  SHELLCHECK  #
# ------------ #

# sed part is to edit shellcheck output so csdiff/csgrep knows it is shellcheck output (--format=gcc)
shellcheck --format=gcc --exclude="${string_of_exceptions}" "${list_of_changed_scripts[@]}" 2> /dev/null | sed -e 's|$| <--[shellcheck]|' > ../pr-br-shellcheck.err

# make destination branch
# shellcheck disable=SC2086
git checkout -q -b ci_br_dest $INPUT_BASE

shellcheck --format=gcc --exclude="${string_of_exceptions}" "${list_of_changed_scripts[@]}" 2> /dev/null | sed -e 's|$| <--[shellcheck]|' > ../dest-br-shellcheck.err

# ------------ #
#  VALIDATION  #
# ------------ #

exit_status=0

# Check output for Fixes
csdiff --fixed "../dest-br-shellcheck.err" "../pr-br-shellcheck.err" > ../fixes.log

if [ -s ../fixes.log ]; then
  echo -e "✅ ${GREEN}Fixed bugs${NOCOLOR}"
  csgrep ../fixes.log
else
  echo -e "ℹ️ ${YELLOW}No Fixes!${NOCOLOR}"
fi

echo

# Check output for added bugs
csdiff --fixed "../pr-br-shellcheck.err" "../dest-br-shellcheck.err" > ../bugs.log

if [ -s ../bugs.log ]; then
  echo -e "✋ ${YELLOW}Added bugs, NEED INSPECTION${NOCOLOR}"
  csgrep ../bugs.log
  exit_status=1
else
  echo -e "🥳 ${GREEN}No bugs added Yay!${NOCOLOR}"
  exit_status=0
fi

# SARIF upload
if [ -n "$INPUT_TOKEN" ]; then
  echo
  # GitHub support absolute path, so let's remove './' from file path
  csgrep --strip-path-prefix './' --mode=sarif ../bugs.log >> output.sarif && uploadSARIF
fi

summary >> "$GITHUB_STEP_SUMMARY"

exit $exit_status
