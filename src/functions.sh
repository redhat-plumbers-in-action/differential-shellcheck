# shellcheck shell=bash
# Function to check whether input param is on list of shell scripts
# $1 - <string> absolute path to file
# $@ - <array of strings> list of strings to compare with
# $? - return value - 0 when succes
is_it_script () {
  [ $# -le 1 ] && return 1
  local file="$1"
  shift
  local scripts=("$@")

  [[ " ${scripts[*]} " =~ " ${file} " ]] && return 0 || return 2
}

# Function to check if given file has .sh extension
# https://stackoverflow.com/a/6926061
# $1 - <string> absolute path to file
# $? - return value - 0 when succes
check_extension () {
  [ $# -le 0 ] && return 1
  local file="$1"

  case $file in
    *.sh) return 0;;
    *.bash) return 0;;
    *) return 2
  esac
}

# Function to check if given file contain shell shebang (bash or sh)
# https://unix.stackexchange.com/a/406939
# $1 - <string> absolute path to file
# $? - return value - 0 when succes
check_shebang () {
  [ $# -le 0 ] && return 1
  local file="$1"

  if IFS= read -r line < "./${file}" ; then
    case $line in
      "#!/bin/bash") return 0;;
      "#!/bin/sh") return 0;;
      *) return 1
    esac
  fi
}

# Function to prepare string from array of strings where first argument specify one character separator
# https://stackoverflow.com/a/17841619
# $1 - <char> Character used to join elements of array
# $@ - <array of string> list of strings
# return value - string
join_by () {
  local IFS="$1"
  shift
  echo "$*"
}

# Function to get rid of comments represented by '#'
# $1 - file path
# $2 - name of variable where will be stored result array
# $3 - value 1|0 - does file content inline comments?
# $? - return value - 0 when succes
file_to_array () {
  [ $# -le 2 ] && return 1
  local output=()

  [ "$3" -eq 0 ] && readarray output < <(grep -v "^#.*" "$1")                         # fetch array with lines from file while excluding '#' comments  
  [ "$3" -eq 1 ] && readarray output < <(cut -d ' ' -f 1 < <(grep -v "^#.*" "$1"))    # fetch array with lines from file while excluding '#' comments
  clean_array "$2" "${output[@]}" && return 0
}

# Function to get rid of spaces and new lines from array elements
# https://stackoverflow.com/a/9715377
# https://stackoverflow.com/a/19347380
# https://unix.stackexchange.com/a/225517
# $1 - name of variable where will be stored result array
# $@ - source array
# $? - return value - 0 when succes
clean_array () {
  [ $# -le 1 ] && return 1
  local output="$1"
  shift
  local input=("$@")

  for i in "${input[@]}"; do
    eval $output+=\("${i//[$'\t\r\n ']}"\)
  done
}

# Function to check if action is run in Debug mode
isDebug () {
  [[ "${RUNNER_DEBUG}" -eq 1 ]] && return 0 || return 1
}

# Function to upload SARIF report to GitHub
# Source: https://github.com/github/codeql-action/blob/dbe6f211e66b3aa5e9a5c4731145ed310ed54e28/lib/upload-lib.js#L104-L106
# Parameters: https://github.com/github/codeql-action/blob/69e09909dc219ed3374913e41c167490fc57202a/lib/upload-lib.js#L211-L224
# Values: https://github.com/github/codeql-action/blob/main/lib/upload-lib.test.js#L72
uploadSARIF () {
  isDebug && local verbose=--verbose

  curl_args=(
    "${verbose:---silent}"
    -X PUT
    -f "https://api.github.com/repos/${GITHUB_REPOSITORY}/code-scanning/analysis"
    -H "Authorization: token ${INPUT_TOKEN}"
    -H "Accept: application/vnd.github.v3+json"
    -d '{"commit_oid":"'"${INPUT_HEAD}"'","ref":"'"${GITHUB_REF//merge/head}"'","analysis_key":"differential-shellcheck","sarif":"'"$(gzip -c output.sarif | base64 -w0)"'","tool_names":["differential-shellcheck"]}'
  )

  if curl "${curl_args[@]}" &> curl_std ; then
    echo -e "✅ ${GREEN}SARIF report was successfully uploaded to GitHub${NOCOLOR}"
    isDebug && cat curl_std
  else
    echo -e "❌ ${RED}Fail to upload SARIF to GitHub${NOCOLOR}"
    cat curl_std
  fi
}

summary () {
  local fixed_issues
  fixed_issues=$(grep -Eo "[0-9]*" < <(csgrep --mode=stat ../fixes.log))

  local added_issues
  added_issues=$(grep -Eo "[0-9]*" < <(csgrep --mode=stat ../bugs.log))

  echo -e "\
### Differential ShellCheck 🐚

Changed scripts: \`${#list_of_changed_scripts[@]}\`

|                             | ❌ Added | ✅ Fixed |
|:---------------------------:|:-------:|:-------:|
| ⚠️ [Errors / Warnings / Notes](https://github.com/${GITHUB_REPOSITORY}/pull/${GITHUB_REF//merge}/files) |  **${added_issues:-0}**  |  **${fixed_issues:-0}**  |

#### Useful links

- [Differential ShellCheck Documentation](https://github.com/redhat-plumbers-in-action/differential-shellcheck#readme)
- [ShellCheck Documentation](https://github.com/koalaman/shellcheck#readme)

---
_ℹ️ When you have an issue with GitHub action please try to run it in [debug mode](https://github.blog/changelog/2022-05-24-github-actions-re-run-jobs-with-debug-logging/) and submit an [issue](https://github.com/redhat-plumbers-in-action/differential-shellcheck/issues/new)._"
}

# Logging aliases, use echo -e to use them
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
