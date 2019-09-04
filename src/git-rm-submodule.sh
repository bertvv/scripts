#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Completely removes a Git submodule.
#
# See usage() for details.

#{{{ Bash settings
# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail
#}}}
#{{{ Variables
readonly SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

readonly LOG_FILE=$(mktemp)

readonly BLUE='\e[0;34m'
readonly YELLOW='\e[0;33m'
readonly GREEN='\e[0;32m'
readonly RED='\e[0;31m'
readonly RESET='\e[0m'
#}}}

main() {
  check_args "$@"
  remove_git_submodules "$@"
}

#{{{ Helper functions

# Check if command line arguments are valid
check_args() {
  if [ "${#}" -lt "1" ]; then
    echo -e "${RED}Expected at least 1 argument, got ${#}${RESET}" >&2
    usage
    exit 2
  fi

  if [ ! -d "${PWD}/.git" ]; then
    echo -e "${RED}fatal: Not a git repository${RESET}" >&2
    usage
    exit 1
  fi
}

# For each argument, run the function remove_git_submodule
remove_git_submodules() {
  for module in "${@}"; do
    echo -e "${YELLOW}--- Removing module ${module} ---${RESET}"
    remove_git_submodule "${module}"
  done
}

# Removes the specified Git submodule completely
remove_git_submodule() {
  local submodule="${1}"

  echo -en "  deinit module                          "
  git submodule deinit "${submodule}" >> "${LOG_FILE}" 2>&1 || fail
  echo -e "${GREEN}[ OK ]${RESET}"

  echo -en "  removing module from working directory "
  git rm "${submodule}" >> "${LOG_FILE}" 2>&1 || fail
  echo -e "${GREEN}[ OK ]${RESET}"

  echo -en "  removing module from .git/             "
  rm -rf ".git/modules/${submodule}" >> "${LOG_FILE}" 2>&1 || fail
  echo -e "${GREEN}[ OK ]${RESET}"
}

# Print failure message, error messages and exit
fail() {
  echo -e "${RED}[FAIL]${RESET}"
  cat "${LOG_FILE}"
  rm "${LOG_FILE}"
  exit 1
}


# Print usage message on stdout
usage() {
cat << _EOF_
Usage: ${0} [MODULE]

  Completely removes a Git submodule. This command should be run from the
  root directory of your local Git workin directory.

EXAMPLES:
_EOF_
}

#}}}

main "$@"

