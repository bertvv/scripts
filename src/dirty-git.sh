#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
#/ Usage: dirty-git [OPTIONS]... [DIR]
#/
#/ Search the specified directory (or the user's home) for Git repositories with
#/ local changes.
#/
#/ OPTIONS
#/   -h, --help
#/                 Print this help message and exit
#/   -v, --verbose
#/                 Also print clean repositories
#/
#/ EXAMPLES
#/  dirty-git
#/  dirty-git -v Development

#{{{ Bash settings
# abort on nonzero exitstatus
#set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail
#}}}
#{{{ Variables
readonly script_name=$(basename "${0}")
readonly script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

# Color definitions
readonly reset='\e[0m'
readonly cyan='\e[0;36m'
readonly red='\e[0;31m'
readonly yellow='\e[0;33m'
readonly green='\e[0;32m'
# Debug info ('on' to enable)
readonly debug='off'

readonly status_ok="${green}✓${reset}"
readonly status_fail="${red}✗${reset}"

#
# Default configuration, to be changed with command line arguments
#

# Verbosity:
# 0 - only print repos with local changes
# 1 - also print clean repos
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
        debug "Setting verbosity on"
        verbosity=1
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
  repos=$(find "${search_dir}" -type d -name '.git')

  for repo in ${repos}; do
    repo_dir="${repo%.git}"
    debug "Checking ${repo_dir}"
    if is_repo_clean "${repo_dir}"; then
      debug "Clean"
      if [ "${verbosity}" -eq '1' ]; then
        num_clean=$(( num_clean + 1 ))
        printf '%b %s\n' "${status_ok}" "${repo_dir}"
      fi
    else
      debug "Dirty"
      num_dirty=$(( num_dirty + 1 ))
      printf '%b %s\n' "${status_fail}" "${repo_dir}"
    fi
  done

  log "Found ${num_dirty} repos with local changes"

  if [ "${verbosity}" -eq 1 ]; then
    log "Found ${num_clean} clean repos"
  fi
}

# Usage: is_repo_clean DIR
#  Checks whether the specified Got repo is clean
#  Returns with exit status 0 if no local changes are present, a nonzero in any
#  other case
is_repo_clean() {
  local git_repo="${1}"
  local result

  pushd "${git_repo}" > /dev/null
  result=$(git status --short)
  popd > /dev/null

  # Repo is clean if ${result} is empty
  [ -z "${result}" ]
}

# Print usage message on stdout by parsing start of script comments
usage() {
  grep '^#/' "${script_dir}/${script_name}" | sed 's/^#\/\w*//'
}

# Usage: log [ARG]...
#
# Prints all arguments on the standard error stream
log() {
  printf "${yellow}>>> %s${reset}\\n" "${*}" >&2
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard output stream,
# if debug output is enabled
debug() {
  [ "${debug}" != 'on' ] || printf "${cyan}### %s${reset}\\n" "${*}" >&2
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf "${red}!!! %s${reset}\\n" "${*}" 1>&2
}


#}}}

main "${@}"

