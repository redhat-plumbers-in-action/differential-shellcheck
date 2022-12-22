# shellcheck shell=bash
# SPDX-License-Identifier: GPL-3.0-or-later

get_fixes () {
  [[ $# -le 1 ]] && return 1

  csdiff --fixed "${1}" "${2}" > ../fixes.log
}

evaluate_and_print_fixes () {
  if [[ -s ../fixes.log ]]; then
    echo -e "✅ ${GREEN}Fixed defects${NOCOLOR}"
    csgrep ../fixes.log
  else
    echo -e "ℹ️ ${YELLOW}No Fixes!${NOCOLOR}"
  fi
}

get_defects () {
  [[ $# -le 1 ]] && return 1

  csdiff --fixed "${1}" "${2}" > ../defects.log
}

evaluate_and_print_defects () {
  if [[ -s ../defects.log ]]; then
    echo -e "✋ ${YELLOW}Defects, NEEDS INSPECTION${NOCOLOR}"
    csgrep ../defects.log
    return 1
  fi

  echo -e "🥳 ${GREEN}No defects added. Yay!${NOCOLOR}"
}
