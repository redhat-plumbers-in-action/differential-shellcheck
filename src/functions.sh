# shellcheck shell=bash
# SPDX-License-Identifier: GPL-3.0-or-later

# Function to check whether the input param is on the list of shell scripts
# $1 - <string> absolute path to a file
# $@ - <array of strings> list of strings to compare with
# $? - return value - 0 on success
is_script_listed () {
  [[ $# -le 1 ]] && return 1
  local file="$1"
  shift
  local scripts=("$@")

  [[ "${scripts[*]}" =~ ${file} ]] && return 0 || return 2
}

# Function to check whether the given file has the .{,a,ba,da,k}sh and .bats extension
# https://stackoverflow.com/a/6926061
# $1 - <string> absolute path to a file
# $? - return value - 0 on success
is_shell_extension () {
  [[ $# -le 0 ]] && return 1
  local file="$1"

  case $file in
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
  if head -n1 "${file}" | grep -E '^\s*((\#|\!)|(\#\s*\!)|(\!\s*\#))\s*(\/usr(\/local)?)?\/bin\/(env\s+)?(sh|ash|bash|dash|ksh|bats)\b'; then
    return 0
  fi

  # ShellCheck shell directive detection
  if grep -E '^\s*\#\s*shellcheck\s+shell=(sh|ash|bash|dash|ksh|bats)\s*' "${file}"; then
    return 0
  fi

  # Emacs mode detection
  if grep -E '^\s*\#\s+-\*-\s+(sh|ash|bash|dash|ksh|bats)\s+-\*-\s*' "${file}"; then
    return 0
  fi

  # Vi and Vim modeline filetype detection
  if grep -E '^\s*\#\s+vim?:\s+(set\s+)?(ft|filetype)=(sh|ash|bash|dash|ksh|bats)\s*' "${file}"; then
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

# Function to concatenate an array of strings where the first argument
# specifies the separator
# https://stackoverflow.com/a/17841619
# $1 - <char> character used to join the elements of the array
# $@ - <array of strings> list of strings
# return value - string
join_by () {
  local IFS="$1"
  shift
  echo "$*"
}

# Function to get rid of comments represented by '#'
# $1 - file path
# $2 - name of a variable where the result array will be stored
# $3 - value 1|0 - does the file contain inline comments?
# $? - return value - 0 on success
file_to_array () {
  [[ $# -le 2 ]] && return 1
  local output=()

  [[ "$3" -eq 0 ]] && readarray output < <(grep -v "^#.*" "$1")                         # fetch the array with lines from the file while excluding '#' comments
  [[ "$3" -eq 1 ]] && readarray output < <(cut -d ' ' -f 1 < <(grep -v "^#.*" "$1"))    # fetch the array with lines from the file while excluding '#' comments
  clean_array "$2" "${output[@]}" && return 0
}

# Function to trim spaces and new lines from array elements
# https://stackoverflow.com/a/9715377
# https://stackoverflow.com/a/19347380
# https://unix.stackexchange.com/a/225517
# $1 - name of a variable where the result array will be stored
# $@ - source array
# $? - return value - 0 on success
clean_array () {
  [[ $# -le 1 ]] && return 1
  local output="$1"
  shift
  local input=("$@")

  for i in "${input[@]}"; do
    eval $output+=\("${i//[$'\t\r\n ']}"\)
  done
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
    --format=gcc
    "${external_sources:-}"
    --severity="${INPUT_SEVERITY}"
    --exclude="${string_of_exceptions}"
    "${list_of_changed_scripts[@]}"
  )

  local output
  output=$(shellcheck "${shellcheck_args[@]}" 2> /dev/null | sed -e 's|$| <--[shellcheck]|')

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
    -d '{"commit_oid":"'"${INPUT_HEAD}"'","ref":"'"${GITHUB_REF//merge/head}"'","analysis_key":"differential-shellcheck","sarif":"'"$(gzip -c output.sarif | base64 -w0)"'","tool_names":["differential-shellcheck"]}'
  )

  if curl "${curl_args[@]}" &> curl_std ; then
    echo -e "✅ ${GREEN}SARIF report was successfully uploaded to GitHub${NOCOLOR}"
    is_debug && cat curl_std
  else
    echo -e "❌ ${RED}Failed to upload the SARIF report to GitHub${NOCOLOR}"
    cat curl_std
  fi
}

summary () {
  local fixed_issues
  fixed_issues=$(grep -Eo "[0-9]*" < <(csgrep --mode=stat ../fixes.log))

  local added_issues
  added_issues=$(grep -Eo "[0-9]*" < <(csgrep --mode=stat ../defects.log))

  local pull_number=${GITHUB_REF##refs\/}
  pull_number=${pull_number%%\/merge}

  echo -e "\
### Differential ShellCheck 🐚

Changed scripts: \`${#list_of_changed_scripts[@]}\`

|                             | ❌ Added | ✅ Fixed |
|:---------------------------:|:-------:|:-------:|
| ⚠️ [Errors / Warnings / Notes](https://github.com/${GITHUB_REPOSITORY}/${pull_number}/files) |  **${added_issues:-0}**  |  **${fixed_issues:-0}**  |

#### Useful links

- [Differential ShellCheck Documentation](https://github.com/redhat-plumbers-in-action/differential-shellcheck#readme)
- [ShellCheck Documentation](https://github.com/koalaman/shellcheck#readme)

---
_ℹ️ If you have an issue with this GitHub action, please try to run it in the [debug mode](https://github.blog/changelog/2022-05-24-github-actions-re-run-jobs-with-debug-logging/) and submit an [issue](https://github.com/redhat-plumbers-in-action/differential-shellcheck/issues/new)._"
}

show_versions() {
  local shellcheck
  local csutils

  shellcheck=$(shellcheck --version | grep "version:")
  csutils=$(csdiff --version)

  echo -e "\
ShellCheck: ${shellcheck//'version: '/}
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
