# shellcheck shell=bash
# SPDX-License-Identifier: GPL-3.0-or-later

# Get file containing fixes based on two input files
# $1 - <string> absolute path to a file containing results from BASE scan
# $2 - <string> absolute path to a file containing results from HEAD scan
# $? - return value - 0 on success
# results are returned in file - '../fixes.log'
get_fixes () {
  [[ $# -le 1 ]] && return 1

  csdiff --fixed "${1}" "${2}" > ../fixes.log
}

# Function to evaluate results of fixed defects and to provide feedback on standard output
# It expects file '../fixes.log' to contain fixes
# $? - return value is always 0
evaluate_and_print_fixes () {
  if [[ -s ../fixes.log ]]; then
    echo -e "✅ ${GREEN}Fixed defects${NOCOLOR}"
    csgrep ../fixes.log
  else
    echo -e "ℹ️ ${YELLOW}No Fixes!${NOCOLOR}"
  fi
}

# Get file containing defects based on two input files
# $1 - <string> absolute path to a file containing results from HEAD scan
# $2 - <string> absolute path to a file containing results from BASE scan
# $? - return value - 0 on success
# results are returned in file - '../defects.log'
get_defects () {
  [[ $# -le 1 ]] && return 1

  csdiff --fixed "${1}" "${2}" > ../defects.log
}

# Function to evaluate results of defects and to provide feedback on standard output
# It expects file '../defects.log' to contain defects
# $? - return value - 0 on success
evaluate_and_print_defects () {
  if [[ -s ../defects.log ]]; then
    echo -e "✋ ${YELLOW}Defects, NEEDS INSPECTION${NOCOLOR}"
    csgrep ../defects.log
    return 1
  fi

  echo -e "🥳 ${GREEN}No defects added. Yay!${NOCOLOR}"
}
