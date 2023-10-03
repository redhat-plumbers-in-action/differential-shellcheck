# shellcheck shell=bash
# SPDX-License-Identifier: GPL-3.0-or-later

# shellcheck source=summary.sh
. "${SCRIPT_DIR=}summary.sh"
# shellcheck source=validation.sh
. "${SCRIPT_DIR=}validation.sh"

# Function that determine if FULL scan is requested
# INPUT_TRIGGERING_EVENT is required
# $? - return value - 0 on success
is_full_scan_demanded () {
  case "${INPUT_TRIGGERING_EVENT-${GITHUB_EVENT_NAME}}" in
    "push")
      return 0
      ;;

    "pull_request")
      return 1
      ;;

    "manual")
      is_false "${INPUT_DIFF_SCAN}" && return 0
      ;;

    *)
      # Perform Differential scans by default
  esac

  return 1
}

# Function that determine if strict check on push events is requested
# INPUT_TRIGGERING_EVENT is required
# $? - return value - 0 on success
is_strict_check_on_push_demanded () {
  [[ "${INPUT_TRIGGERING_EVENT-${GITHUB_EVENT_NAME}}" = "push" ]] || return 1
  is_false "${INPUT_STRICT_CHECK_ON_PUSH:-"false"}" && return 2
  return 0
}

# Function that picks values of BASE and HEAD commit based on triggrring event (INPUT_TRIGGERING_EVENT)
# It sets BASE and HEAD for external use.
# $? - return value - 0 on success
pick_base_and_head_hash () {
  case ${INPUT_TRIGGERING_EVENT-${GITHUB_EVENT_NAME}} in
    "push")
      export BASE=${INPUT_PUSH_EVENT_BASE:-}
      export HEAD=${INPUT_PUSH_EVENT_HEAD:-}
      [[ ${UNIT_TESTS:-1} -eq 0 ]] && echo "BASE:\"${BASE}\" ; HEAD:\"${HEAD}\""
      ;;

    "pull_request")
      export BASE=${INPUT_PULL_REQUEST_BASE:-}
      export HEAD=${INPUT_PULL_REQUEST_HEAD:-}
      [[ ${UNIT_TESTS:-1} -eq 0 ]] && echo "BASE:\"${BASE}\" ; HEAD:\"${HEAD}\""
      ;;

    "manual")
      export BASE=${INPUT_BASE:-}
      export HEAD=${INPUT_HEAD:-}
      [[ ${UNIT_TESTS:-1} -eq 0 ]] && echo "BASE:\"${BASE}\" ; HEAD:\"${HEAD}\""
    ;;

    *)
      echo -e "❓ ${RED}Value of required variable INPUT_TRIGGERING_EVENT isn't set or contains unsupported value. Supported values are: (pull_request | push | manual).${NOCOLOR}"
      return 1
  esac

  if [[ -z ${BASE} ]] || [[ -z ${HEAD} ]]; then
    echo -e "❓ ${RED}Value of required variables BASE and/or HEAD isn't set or contains unsupported value.${NOCOLOR}"
    return 2
  fi
}

# Function that returns an array of paths to scripts eligible for scanning
# https://stackoverflow.com/a/12985353/10221282
# $1 - <string> absolute path to a file with list of files
# $2 - <string> name of a variable where the result array will be stored
get_scripts_for_scanning () {
  [[ $# -le 1 ]] && return 1
  local output=$2

  # Find modified shell scripts
  local list_of_changes=()
  file_to_array "${1}" "list_of_changes"

  # Create a list of scripts for testing
  local scripts_for_scanning=()
  for file in "${list_of_changes[@]}"; do
    is_symlink "${file}" && continue
    is_directory "${file}" && continue
    is_matched_by_path "${file}" "${INPUT_EXCLUDE_PATH-}" && continue
    is_matched_by_path "${file}" "${INPUT_INCLUDE_PATH-}" && scripts_for_scanning+=("./${file}") && continue
    is_shell_extension "${file}" && scripts_for_scanning+=("./${file}") && continue
    has_shebang "${file}" && scripts_for_scanning+=("./${file}")
  done

  eval $output=\("${scripts_for_scanning[*]@Q}"\)
  [[ ${UNIT_TESTS:-1} -eq 0 ]] && eval echo "\${${output}[@]@Q}"
}

# Function to check whether the given file has the .{,a,ba,da,k}sh and .bats extension
# https://stackoverflow.com/a/6926061
# $1 - <string> absolute path to a file
# $? - return value - 0 on success
is_shell_extension () {
  [[ $# -le 0 ]] && return 1
  local file="$1"

  case ${file} in
    *.sh) return 0;;
    *.ash) return 0;;
    *.bash) return 0;;
    *.dash) return 0;;
    *.ksh) return 0;;
    *.bats) return 0;;
    *) return 2
  esac
}

# Function to check whether the given file contains a shell shebang
# - supported interpreters are {,a,ba,da,k}sh and bats including shellcheck directive
# - also supports emacs and vi/vim file types specifications
# https://unix.stackexchange.com/a/406939
# emacs: https://www.gnu.org/software/emacs/manual/html_node/emacs/Choosing-Modes.html
# vi/vim: http://vimdoc.sourceforge.net/htmldoc/options.html#modeline
# $1 - <string> absolute path to a file
# $? - return value - 0 on success
has_shebang () {
  [[ $# -le 0 ]] && return 1
  local file="$1"

  # shell shebangs detection
  if head -n1 "${file}" | grep --quiet -E '^\s*((#|!)|(#\s*!)|(!\s*#))\s*(/usr(/local)?)?/bin/(env\s+)?(sh|ash|bash|dash|ksh|bats)\b'; then
    return 0
  fi

  # ShellCheck shell directive detection
  if grep --quiet -E '^\s*#\s*shellcheck\s+shell=(sh|ash|bash|dash|ksh|bats)\s*' "${file}"; then
    return 0
  fi

  # Emacs mode detection
  if grep --quiet -E '^\s*#\s+-\*-\s+(sh|ash|bash|dash|ksh|bats)\s+-\*-\s*' "${file}"; then
    return 0
  fi

  # Vi and Vim modeline filetype detection
  if grep --quiet -E '^\s*#\s+vim?:\s+(set\s+)?(ft|filetype)=(sh|ash|bash|dash|ksh|bats)\s*' "${file}"; then
    return 0
  fi

  return 2
}

# Function to test if given file is symbolic link
# $1 - <string> path to a file
# $? - return value - 0 on success
is_symlink () {
  [[ $# -le 0 ]] && return 1
  local file="$1"

  [[ -L "${file}" ]] && return 0

  return 2
}

# Function to test if given file path is directory
# $1 - <string> file path
# $? - return value - 0 on success
is_directory () {
  [[ $# -le 0 ]] && return 1
  local file="$1"

  [[ -d "${file}" ]] && return 0

  return 2
}

# Function to test if given file path is listed in the privided input list
# https://unix.stackexchange.com/a/165981/509101
# $1 - <string> file path
# $2 - <string> input list of files
# $? - return value - 0 on success
is_matched_by_path () {
  [[ $# -le 1 ]] && return 1
  local file="$1"

  # When multiple paths are provided they might be separated by space and/or newline, lets replace all newlines with spaces in order to avoid issues with glob pattern matching in eval
  # /action/functions.sh: line 215: tests/**: No such file or directory
  local file_paths=""
  file_paths=$(tr '\r\n' ' ' <<< "$2")

  set -f
  globs=$(eval "echo ${file_paths}")

  for pattern in ${globs}; do
    # shellcheck disable=SC2053
    # We want to use glob pattern matching here
    [[ ${file} == ${pattern} ]] && { set +f; return 0; }
  done

  set +f

  return 2
}

# Function that reads a file of paths and stores them in an array
# https://stackoverflow.com/a/28109890/10221282
# $1 - file path
# $2 - name of a variable where the result array will be stored
# $? - return value - 0 on success
file_to_array () {
  [[ $# -le 1 ]] && return 1
  local output=()

  while IFS= read -r -d '' file; do
    is_file_inside_scan_directory "${file}" || continue
    output+=("${file}")
  done < "${1}"

  [[ ${UNIT_TESTS:-1} -eq 0 ]] && echo "${output[@]}"

  eval "${2}"=\("${output[*]@Q}"\)
}

# Function to test if given file is inside the scan directory
# $1 - <string> file path
# $? - return value - 0 on success
is_file_inside_scan_directory () {
  [[ $# -le 0 ]] && return 1
  [[ -z "${INPUT_SCAN_DIRECTORY}" ]] && return 0

  is_matched_by_path "${file}" "${INPUT_SCAN_DIRECTORY}"
  return $?
}

# Evaluate if variable contains true value
# https://github.com/fedora-sysv/initscripts/blob/main/etc/rc.d/init.d/functions#L634-L642
# $1 - variable possibly containing boolean value
# $? - return value - 0 on success
is_true() {
    [[ $# -le 0 ]] && return 1

    case "$1" in
      [tT] | [yY] | [yY][eE][sS] | [oO][nN] | [tT][rR][uU][eE] | 1)
        return 0
        ;;

      *)
        return 1
        ;;
    esac
}

# Evaluate if variable contains false value
# https://github.com/fedora-sysv/initscripts/blob/main/etc/rc.d/init.d/functions#L644-L652
# $1 - variable possibly containing boolean value
# $? - return value - 0 on success
is_false() {
    [[ $# -le 0 ]] && return 1

    case "$1" in
      [fF] | [nN] | [nN][oO] | [oO][fF][fF] | [fF][aA][lL][sS][eE] | 0)
        return 0
        ;;

      *)
        return 1
        ;;
    esac
}

# Function to execute shellcheck command with all relevant options
execute_shellcheck () {
  is_true "${INPUT_EXTERNAL_SOURCES}" && local external_sources=--external-sources

  local shellcheck_args=(
    --format=json1
    "${external_sources:-}"
    --severity="${INPUT_SEVERITY}"
    "${@}"
  )

  local output
  output=$(shellcheck "${shellcheck_args[@]}" 2> /dev/null)

  echo "${output}"
}

# Function to check if the action is run in a Debug mode
is_debug () {
  local result
  result=$(is_true "${RUNNER_DEBUG}")

  # shellcheck disable=SC2086
  # return require numeric value
  return ${result}
}

# Function to upload the SARIF report to GitHub
# Source: https://github.com/github/codeql-action/blob/dbe6f211e66b3aa5e9a5c4731145ed310ed54e28/lib/upload-lib.js#L104-L106
# Parameters: https://github.com/github/codeql-action/blob/69e09909dc219ed3374913e41c167490fc57202a/lib/upload-lib.js#L211-L224
# Values: https://github.com/github/codeql-action/blob/main/lib/upload-lib.test.js#L72
uploadSARIF () {
  is_debug && local verbose=--verbose

  local curl_args=(
    "${verbose:---silent}"
    -X PUT
    -f "https://api.github.com/repos/${GITHUB_REPOSITORY}/code-scanning/analysis"
    -H "Authorization: token ${INPUT_TOKEN}"
    -H "Accept: application/vnd.github.v3+json"
    -d '{"commit_oid":"'"${HEAD}"'","ref":"'"${GITHUB_REF//merge/head}"'","analysis_key":"differential-shellcheck","sarif":"'"$(gzip -c output.sarif | base64 -w0)"'","tool_names":["differential-shellcheck"]}'
  )

  if curl "${curl_args[@]}" &> curl_std; then
    echo -e "✅ ${GREEN}SARIF report was successfully uploaded to GitHub${NOCOLOR}"
    is_debug && cat curl_std
  else
    echo -e "❌ ${RED}Failed to upload the SARIF report to GitHub${NOCOLOR}"
    cat curl_std
  fi
}

get_shellcheck_version () {
  local shellcheck_version
  shellcheck_version=$(shellcheck --version | grep -w "version:" | cut -s -d ' ' -f 2)

  echo "${shellcheck_version}"
}

# Function that shows versions of currently used commands
show_versions() {
  local shellcheck
  local csutils

  shellcheck=$(get_shellcheck_version)
  csutils=$(csdiff --version)

  echo -e "\
ShellCheck: ${shellcheck}
csutils: ${csutils}"
}

# Logging aliases, use echo -e to use them
export VERSIONS_HEADING="\
\n\n:::::::::::::::::::::\n\
::: ${WHITE}Used Versions${NOCOLOR} :::\n\
:::::::::::::::::::::\n"

export MAIN_HEADING="\
\n\n:::::::::::::::::::::::::::::::\n\
::: ${WHITE}Differential ShellCheck${NOCOLOR} :::\n\
:::::::::::::::::::::::::::::::\n"

# Color aliases, use echo -e to use them
export NOCOLOR='\033[0m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export ORANGE='\033[0;33m'
export BLUE='\033[0;34m'
export YELLOW='\033[1;33m'
export WHITE='\033[1;37m'
