#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later

set -o nounset
set -o pipefail

# --- Library path resolution ---
resolve_script_dir () {
  local self
  self="$(readlink -f "$0")"
  local self_dir
  self_dir="$(dirname "${self}")"

  # 1. SCRIPT_DIR already set (dev/test override)
  if [[ -n "${SCRIPT_DIR:-}" ]]; then
    return 0
  fi

  # 2. FHS installed layout: /usr/bin/differential-shellcheck -> /usr/libexec/differential-shellcheck/
  local libexec="${self_dir}/../libexec/differential-shellcheck"
  if [[ -f "${libexec}/index.sh" ]]; then
    SCRIPT_DIR="${libexec}/"
    return 0
  fi

  # 3. Development layout: cli.sh alongside other src/ files
  if [[ -f "${self_dir}/index.sh" ]]; then
    SCRIPT_DIR="${self_dir}/"
    return 0
  fi

  echo "ERROR: Cannot find differential-shellcheck library files" >&2
  return 1
}

# --- Version ---
resolve_version () {
  local self_dir
  self_dir="$(dirname "$(readlink -f "$0")")" || true

  # Check common locations for VERSION file
  for dir in "${self_dir}" "${self_dir}/.." "${self_dir}/../share/differential-shellcheck"; do
    if [[ -f "${dir}/VERSION" ]]; then
      cat "${dir}/VERSION"
      return 0
    fi
  done

  echo "unknown"
}

# --- Usage ---
usage () {
  cat <<'EOF'
Usage: differential-shellcheck [OPTIONS] [--] [FILE ...]

Perform differential ShellCheck scans on shell scripts.

When run without FILE arguments in a Git repository, scans changes between
a base commit (auto-detected from upstream/origin remote) and HEAD.

When FILE arguments are provided, performs a differential scan of those files
against their git-stashed versions (useful as a pre-commit hook).

Differential scan (default in a Git repo):
  --base SHA              Base commit (default: auto-detect from upstream remote)
  --head SHA              Head commit (default: HEAD)
  --upstream REMOTE       Remote to diff against (default: "upstream", fallback: "origin")

Full scan:
  --full-scan             Scan all shell scripts (no differential)

ShellCheck options:
  --severity LEVEL        Minimum severity: error, warning, info, style (default: style)
  --external-sources      Follow source statements (default)
  --no-external-sources   Don't follow source statements

Filtering:
  --scan-directory DIR    Limit scanning to DIR
  --exclude-path PATTERN  Exclude matching paths (repeatable)
  --include-path PATTERN  Include matching paths (repeatable)

Output:
  --display-engine ENG    Display engine: csgrep or sarif-fmt (default: csgrep)

General:
  --verbose               Enable verbose/debug output
  --version               Show version information
  --help                  Show this help message
EOF
}

# --- Argument parsing ---
# Exported as a function so it can be tested in isolation
parse_args () {
  # Handle --help and --version before getopt for portability
  for arg in "$@"; do
    case "${arg}" in
      --help) usage; exit 0 ;;
      --version) echo "differential-shellcheck $(resolve_version || true)"; exit 0 ;;
      *) ;;
    esac
  done

  local opts
  if ! opts=$(getopt \
    --options "" \
    --longoptions "base:,head:,upstream:,full-scan,severity:,external-sources,no-external-sources,scan-directory:,exclude-path:,include-path:,display-engine:,verbose,version,help" \
    --name "differential-shellcheck" \
    -- "$@" 2>&1); then
    echo "ERROR: ${opts}" >&2
    echo "Try 'differential-shellcheck --help' for more information." >&2
    return 2
  fi

  eval set -- "${opts}"

  # Defaults
  INPUT_TRIGGERING_EVENT="manual"
  INPUT_SEVERITY="${INPUT_SEVERITY:-style}"
  INPUT_EXTERNAL_SOURCES="${INPUT_EXTERNAL_SOURCES:-true}"
  INPUT_DISPLAY_ENGINE="${INPUT_DISPLAY_ENGINE:-csgrep}"
  INPUT_DIFF_SCAN="${INPUT_DIFF_SCAN:-true}"
  INPUT_STRICT_CHECK_ON_PUSH="${INPUT_STRICT_CHECK_ON_PUSH:-false}"
  INPUT_SCAN_DIRECTORY="${INPUT_SCAN_DIRECTORY:-}"
  INPUT_EXCLUDE_PATH="${INPUT_EXCLUDE_PATH:-}"
  INPUT_INCLUDE_PATH="${INPUT_INCLUDE_PATH:-}"

  local user_set_base=""
  local user_set_head=""
  CLI_UPSTREAM="${CLI_UPSTREAM:-}"
  CLI_FULL_SCAN=""
  CLI_FILES=()

  while true; do
    case "$1" in
      --base)
        INPUT_BASE="$2"
        user_set_base="1"
        shift 2
        ;;
      --head)
        INPUT_HEAD="$2"
        user_set_head="1"
        shift 2
        ;;
      --upstream)
        CLI_UPSTREAM="$2"
        shift 2
        ;;
      --full-scan)
        CLI_FULL_SCAN="1"
        INPUT_DIFF_SCAN="false"
        shift
        ;;
      --severity)
        case "$2" in
          error|warning|info|style)
            INPUT_SEVERITY="$2"
            ;;
          *)
            echo "ERROR: Invalid severity '$2'. Valid values: error, warning, info, style" >&2
            return 2
            ;;
        esac
        shift 2
        ;;
      --external-sources)
        INPUT_EXTERNAL_SOURCES="true"
        shift
        ;;
      --no-external-sources)
        INPUT_EXTERNAL_SOURCES="false"
        shift
        ;;
      --scan-directory)
        INPUT_SCAN_DIRECTORY="$2"
        shift 2
        ;;
      --exclude-path)
        if [[ -n "${INPUT_EXCLUDE_PATH}" ]]; then
          INPUT_EXCLUDE_PATH="${INPUT_EXCLUDE_PATH}
${2}"
        else
          INPUT_EXCLUDE_PATH="$2"
        fi
        shift 2
        ;;
      --include-path)
        if [[ -n "${INPUT_INCLUDE_PATH}" ]]; then
          INPUT_INCLUDE_PATH="${INPUT_INCLUDE_PATH}
${2}"
        else
          INPUT_INCLUDE_PATH="$2"
        fi
        shift 2
        ;;
      --display-engine)
        INPUT_DISPLAY_ENGINE="$2"
        shift 2
        ;;
      --verbose)
        RUNNER_DEBUG="1"
        shift
        ;;
      --version)
        local ver
        ver="$(resolve_version)" || true
        echo "differential-shellcheck ${ver}"
        exit 0
        ;;
      --help)
        usage
        exit 0
        ;;
      --)
        shift
        break
        ;;
      *)
        echo "ERROR: Unexpected argument '$1'" >&2
        return 2
        ;;
    esac
  done

  # Remaining positional arguments are files
  CLI_FILES=("$@")

  # --- Determine operating mode ---

  if [[ ${#CLI_FILES[@]} -gt 0 ]] && [[ -z "${CLI_FULL_SCAN}" ]]; then
    # Mode 2: Working-tree differential scan (pre-commit style)
    CLI_MODE="worktree-diff"
  elif [[ ${#CLI_FILES[@]} -gt 0 ]] && [[ -n "${CLI_FULL_SCAN}" ]]; then
    # Mode 3: Full scan of specific files
    CLI_MODE="full-scan-files"
  elif [[ -n "${CLI_FULL_SCAN}" ]]; then
    # Mode 3: Full scan of all detected scripts
    CLI_MODE="full-scan"
  else
    # Mode 1: Commit-range differential scan
    CLI_MODE="commit-diff"

    # Auto-detect base if not explicitly set
    if [[ -z "${user_set_base}" ]]; then
      auto_detect_base
    fi

    if [[ -z "${user_set_head}" ]]; then
      INPUT_HEAD="$(git rev-parse HEAD 2>/dev/null)" || {
        echo "ERROR: Cannot resolve HEAD. Are you in a Git repository?" >&2
        return 2
      }
    fi
  fi

  # Export all INPUT_* variables for index.sh
  export INPUT_TRIGGERING_EVENT INPUT_SEVERITY INPUT_EXTERNAL_SOURCES
  export INPUT_DISPLAY_ENGINE INPUT_DIFF_SCAN INPUT_STRICT_CHECK_ON_PUSH
  export INPUT_SCAN_DIRECTORY INPUT_EXCLUDE_PATH INPUT_INCLUDE_PATH
  export INPUT_BASE="${INPUT_BASE:-}" INPUT_HEAD="${INPUT_HEAD:-}"
  export RUNNER_DEBUG="${RUNNER_DEBUG:-0}"

  is_unit_tests && return 0
  return 0
}

# --- Auto-detect base commit from upstream remote ---
auto_detect_base () {
  local remote=""

  if [[ -n "${CLI_UPSTREAM}" ]]; then
    remote="${CLI_UPSTREAM}"
  elif git remote | grep -q "^upstream$" 2>/dev/null; then
    remote="upstream"
  elif git remote | grep -q "^origin$" 2>/dev/null; then
    remote="origin"
  fi

  if [[ -n "${remote}" ]]; then
    local default_branch
    default_branch=$(git remote show "${remote}" 2>/dev/null | sed -n 's/.*HEAD branch: //p')

    if [[ -n "${default_branch}" ]]; then
      INPUT_BASE=$(git merge-base "${remote}/${default_branch}" HEAD 2>/dev/null) && return 0
    fi

    # Fallback: try common branch names
    for branch in main master; do
      INPUT_BASE=$(git merge-base "${remote}/${branch}" HEAD 2>/dev/null) && return 0
    done
  fi

  # Last resort: HEAD~1
  INPUT_BASE=$(git rev-parse HEAD~1 2>/dev/null) || {
    echo "WARNING: Cannot determine base commit. Use --base to specify." >&2
    INPUT_DIFF_SCAN="false"
    CLI_MODE="full-scan"
  }
}

# --- Working-tree differential scan (Mode 2) ---
run_worktree_diff () {
  # shellcheck source=functions.sh
  . "${SCRIPT_DIR}functions.sh"
  # shellcheck source=setup.sh
  . "${SCRIPT_DIR}setup.sh"

  local only_changed_scripts=("${CLI_FILES[@]}")

  # shellcheck disable=SC2154
  echo -e "${VERSIONS_HEADING}"
  show_versions

  # shellcheck disable=SC2154
  echo -e "${MAIN_HEADING}"

  # shellcheck disable=SC2154
  emit_group_start "📜 ${WHITE}List of shell scripts for scanning${NOCOLOR}"
    echo "${only_changed_scripts[*]}"
  emit_group_end
  echo

  local exit_status=0

  # Scan current state (HEAD)
  execute_shellcheck "${only_changed_scripts[@]}" > "${WORK_DIR}head-shellcheck-raw.err"
  csgrep --mode=json --embed-context 4 "${WORK_DIR}head-shellcheck-raw.err" > "${WORK_DIR}head-shellcheck.err"

  # Stash current changes to get base state (HEAD)
  git stash push --quiet 2>/dev/null

  # Scan base state
  execute_shellcheck "${only_changed_scripts[@]}" > "${WORK_DIR}base-shellcheck-raw.err"
  csgrep --mode=json --embed-context 4 "${WORK_DIR}base-shellcheck-raw.err" > "${WORK_DIR}base-shellcheck.err"

  # Restore working state
  git stash pop --quiet 2>/dev/null

  get_fixes "${WORK_DIR}base-shellcheck.err" "${WORK_DIR}head-shellcheck.err"
  evaluate_and_print_fixes

  get_defects "${WORK_DIR}head-shellcheck.err" "${WORK_DIR}base-shellcheck.err"

  echo

  evaluate_and_print_defects
  exit_status=$?

  local summary_text
  summary_text="$(summary)"
  emit_summary "${summary_text}"

  return "${exit_status}"
}

# --- Main ---
main () {
  resolve_script_dir || exit 2

  # Minimal stub for parse_args: is_unit_tests check
  if ! type is_unit_tests &>/dev/null; then
    is_unit_tests () {
      [[ -z "${UNIT_TESTS:-}" ]] && return 1
      return 0
    }
  fi

  parse_args "$@" || exit $?

  # Set up temporary work directory
  WORK_DIR="$(mktemp -d)/"
  export WORK_DIR
  trap 'rm -rf "${WORK_DIR}"' EXIT

  export SCRIPT_DIR

  case "${CLI_MODE}" in
    "worktree-diff")
      run_worktree_diff
      exit $?
      ;;

    *)
      # Modes: commit-diff, full-scan, full-scan-files
      # Delegate to index.sh which handles sourcing and scanning
      export CLI_FILES
      # shellcheck source=index.sh
      . "${SCRIPT_DIR}index.sh"
      ;;
  esac
}

main "$@"
