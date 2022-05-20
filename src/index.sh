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
  is_it_script "$file" "${list_of_scripts[@]}" && list_of_changed_scripts+=("./${file}") && continue
  check_extension "$file" && list_of_changed_scripts+=("./${file}") && continue
  check_shebang "$file" && list_of_changed_scripts+=("./${file}")
done

# Expose list_of_changed_scripts[*] for use inside GA workflow
echo "LIST_OF_SCRIPTS=${list_of_changed_scripts[*]}" >> "$GITHUB_ENV"

# Get list of exceptions
list_of_exceptions=()
[ -f "$INPUT_IGNORED_CODES" ] && file_to_array "$INPUT_IGNORED_CODES" "list_of_exceptions" 1
string_of_exceptions=$(join_by , "${list_of_exceptions[@]}")

echo -e "\n"
echo ":::::::::::::::::::::"
echo -e "::: ${WHITE}Shellcheck CI${NOCOLOR} :::"
echo ":::::::::::::::::::::"
echo -e "\n"

echo -e "${WHITE}Changed shell scripts:${NOCOLOR}"
echo "${list_of_changed_scripts[@]}"
echo -e "${WHITE}List of shellcheck exceptions:${NOCOLOR}"
echo "${string_of_exceptions}"
echo -e "\n"

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

exitstatus=0
echo ":::::::::::::::::::::::::"
echo -e "::: ${WHITE}Validation Output${NOCOLOR} :::"
echo ":::::::::::::::::::::::::"
echo -e "\n"

# Check output for Fixes
csdiff --fixed "../dest-br-shellcheck.err" "../pr-br-shellcheck.err" > ../fixes.log

# Expose number of solved issues for use inside GA workflow
no_fixes=$(grep -Eo "[0-9]*" < <(csgrep --mode=stat ../fixes.log))
echo "NUMBER_OF_SOLVED_ISSUES=${no_fixes:-0}" >> "$GITHUB_ENV"

if [ "$(cat ../fixes.log | wc -l)" -ne 0 ]; then
  echo -e "${GREEN}Fixed bugs:${NOCOLOR}"
  csgrep ../fixes.log
  echo "---------------------"
else
  echo -e "${YELLOW}No Fixes!${NOCOLOR}"
  echo "---------------------"
fi
echo -e "\n"

# Check output for added bugs
csdiff --fixed "../pr-br-shellcheck.err" "../dest-br-shellcheck.err" > ../bugs.log

# Expose number of added issues for use inside GA workflow
no_issues=$(grep -Eo "[0-9]*" < <(csgrep --mode=stat ../bugs.log))
echo "NUMBER_OF_ADDED_ISSUES=${no_issues:-0}" >> "$GITHUB_ENV"

if [ "$(cat ../bugs.log | wc -l)" -ne 0 ]; then
  echo -e "${RED}Added bugs, NEED INSPECTION:${NOCOLOR}"
  csgrep ../bugs.log
  echo "---------------------"
  exitstatus=1
else
  echo -e "${GREEN}No bugs added Yay!${NOCOLOR}"
  echo "---------------------"
  exitstatus=0
fi

exit $exitstatus
