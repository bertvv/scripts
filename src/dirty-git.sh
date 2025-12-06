#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
#: Usage: dirty-git [OPTIONS]... [DIR]
#:
#: Search the specified directory (or the user's home) for Git repositories with
#: local changes.
#:
#: OPTIONS
#:   -h, --help
#:                 Print this help message and exit
#:   -v, --verbose
#:                 Increase verbosity level (default = 0)
#:                 Can be repeated with -v -v or -vv
#:
#: VERBOSITY
#: 
#:   0  Only show repos with local changes
#:   1  Also show repos without local changes
#:   2  Also show debug output
#:   3- Higher values are ignored
#:
#: EXAMPLES
#:   dirty-git
#:   dirty-git -v Development
#:   dirty-git -vv Development

#{{{ Bash settings
# abort on nonzero exitstatus
#set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail
#}}}
#{{{ Variables
script_name=$(basename "${0}")
script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly script_dir script_name
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

readonly status_ok="\e[0;32m✓\e[0m"
readonly status_fail="\e[0;31m✗\e[0m"

#
# Default configuration, to be changed with command line arguments
#

# Verbosity:
# 0 - only print repos with local changes
# 1 - also print clean repos
# 2 - also print debug output
verbosity=0

# Directory to be searched
search_dir="${HOME}"
#}}}

main() {
  check_args "${@}"
  search_git_dirs
}

#{{{ Helper functions

check_args() {
  while [ "$#" -gt '0' ]; do
    case "${1}" in
      -h|--help)
        usage
        exit 0
        ;;
      -v|--verbose)
        debug "Increasing verbosity level"
        verbosity=$(( verbosity + 1 ))
        shift
        ;;
      -vv)
        debug "Increasing verbosity level 2x"
        verbosity=$(( verbosity + 2 ))
        shift
        ;;
      -*)
        error "Unrecognized option: ${1}"
        usage
        exit 2
        ;;
      *)
        debug "Setting search directory"
        search_dir="${1}"
        if [ ! -d "${search_dir}" ]; then
          error "${search_dir} is not a directory"
          usage
          exit 3
        fi
        break
        ;;
    esac
  done
}

search_git_dirs() {
  log "Searching directory ${search_dir}"
  debug "Verbosity: ${verbosity}"

  local num_dirty=0
  local num_clean=0
  local repos
  repos=$(find "${search_dir}" -type d -name '.git' 2> /dev/null)

  for repo in ${repos}; do
    repo_dir="${repo%.git}"
    debug "Checking ${repo_dir}"

    if is_repo_clean "${repo_dir}"; then
      debug "Clean"
      num_clean=$(( num_clean + 1 ))
      list_clean "${repo_dir}"
    else
      debug "Dirty"
      num_dirty=$(( num_dirty + 1 ))
      list_dirty "${repo_dir}"
    fi
  done

  log "Found ${num_dirty} repos with local changes"
  log "Found ${num_clean} clean repos"
}

# Usage: list_clean PATH
#   Print the path to the specified directory as a clean repo.
list_clean() {
  local path="${1}"

  if [ "${verbosity}" -ge '1' ]; then
    printf '%b %s\n' "${status_ok}" "${path}"
  fi

}

# Usage: list_dirty PATH
#   Print the path to the specified directory as a repo with local changes.
list_dirty() {
  local path="${1}"

  printf '%b %s\n' "${status_fail}" "${repo_dir}"
}

# Usage: is_repo_clean DIR
#  Checks whether the specified Got repo is clean
#  Returns with exit status 0 if no local changes are present, a nonzero in any
#  other case
is_repo_clean() {
  local git_repo="${1}"
  local result

  pushd "${git_repo}" > /dev/null || exit 4
  result=$(git status --short)
  popd > /dev/null || exit 4

  # Repo is clean if ${result} is empty
  [ -z "${result}" ]
}

# Print usage message on stdout by parsing start of script comments
usage() {
  grep '^#:\s*' "${script_dir}/${script_name}" \
    | cut --characters=4-
}

# Usage: log MESSAGE...
#  Prints a log message to stdout.
log() {
  local message="$*"
  printf 'ℹ️ \033[1;34m%s\033[0m\n' "${message}"
}

# Usage: debug MESSAGE...
#  Prints a debug message to stderr, if debug output is turned on.
debug() {
  if [ "${verbosity}" -ge '2' ]; then
    local message="$*"
    printf '🐛 \033[1;33m%s\033[0m\n' "${message}" >&2
  fi
}

# Usage: error MESSAGE...
#  Prints an error message to stderr.
error() {
  local message="$*"
  printf '🚨 \033[1;31m%s\033[0m\n' "${message}" >&2
}

#}}}

main "${@}"

