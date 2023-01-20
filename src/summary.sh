# shellcheck shell=bash
# SPDX-License-Identifier: GPL-3.0-or-later

# Print scanning summary
summary () {
  scan_summary=""
  if [[ ${FULL_SCAN} -eq 0 ]] && is_strict_check_on_push_demanded; then
    scan_summary=$(full_scan_summary)
  else
    scan_summary=$(diff_scan_summary)
  fi

  local useful_links=
  useful_links=$(summary_useful_links)
  
  echo -e "\
### Differential ShellCheck 🐚

${scan_summary}

${useful_links}"
}

# Handle scanning summary for standard (full) scans
full_scan_summary () {
  local results_link
  results_link=$(compose_results_link "Defects")

  local added_issues
  added_issues=$(get_number_of defects)

  echo -e "\
Number of scripts: \`${#all_scripts[@]}\`

${results_link}: **${added_issues:-0}**"
}

# Handle scanning summary for differential scans
diff_scan_summary () {
  local results_link
  results_link=$(compose_results_link "Errors / Warnings / Notes")

  local fixed_issues
  fixed_issues=$(get_number_of fixes)

  local added_issues
  added_issues=$(get_number_of defects)

  echo -e "\
Changed scripts: \`${#only_changed_scripts[@]}\`

|                    | ❌ Added                 | ✅ Fixed                 |
|:------------------:|:------------------------:|:------------------------:|
| ⚠️ ${results_link} |  **${added_issues:-0}**  |  **${fixed_issues:-0}**  |"
}

# Get number of fixed issues or added defects
# $1 - <fixes | defects> a name of statistics
# $? - return value - 0 on success
get_number_of () {
  [[ $# -le 0 ]] && return 1

  grep -Eo "[0-9]*" < <(csgrep --mode=stat ../"${1}".log)
}

# Create full Markdown style link to results
# When no link is available it returns regular text
# Link is printed on std output
# $? - return value - 0 on success
compose_results_link () {
  [[ ${#1} -le 0 ]] && return 1

  local results_link_title="${1}"
  local link=""
  link=$(link_to_results)
  results_link=""

  [[ -z "${link}" ]] && results_link="${results_link_title}"
  [[ -n "${link}" ]] && results_link="[${results_link_title}](${link})"

  echo -e "${results_link}"
}

# Get links to results based on triggering event
# Link is printed on std output
# $? - return value - 0 on success
link_to_results () {
  local pull_number=${GITHUB_REF##refs\/pull\/}
  pull_number=${pull_number%%\/merge}

  # !FIXME: Currently variable `tool` doesn't exist ...
  local push_link="https://github.com/${GITHUB_REPOSITORY}/security/code-scanning?query=tool%3A${SCANNING_TOOL:-"shellcheck"}+branch%3A${GITHUB_REF_NAME:-"main"}+is%3Aopen"
  local pull_request_link="https://github.com/${GITHUB_REPOSITORY}/security/code-scanning?query=pr%3A${pull_number}+tool%3A${SCANNING_TOOL:-"shellcheck"}+is%3Aopen"

  case ${INPUT_TRIGGERING_EVENT-${GITHUB_EVENT_NAME}} in
    "push")
      echo -e "${push_link}"
      ;;

    "pull_request")
      echo -e "${pull_request_link}"
      ;;

    *)
      echo -e ""
  esac 
}

# Print useful information at the end of summary report
# $? - return value - 0 on success
summary_useful_links () {
  echo -e "\
#### Useful links

- [Differential ShellCheck Documentation](https://github.com/redhat-plumbers-in-action/differential-shellcheck#readme)
- [ShellCheck Documentation](https://github.com/koalaman/shellcheck#readme)

---
_ℹ️ If you have an issue with this GitHub action, please try to run it in the [debug mode](https://github.blog/changelog/2022-05-24-github-actions-re-run-jobs-with-debug-logging/) and submit an [issue](https://github.com/redhat-plumbers-in-action/differential-shellcheck/issues/new)._"
}
