#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Install the specified Ansible roles in ~/.ansible/roles

#{{{ Bash settings
# abort on nonzero exitstatus
set -o errexit
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

readonly galaxy_user=bertvv
readonly roles=$(ansible-galaxy search --author "${galaxy_user}" | grep "${galaxy_user}" | awk '{print $1}')

#}}}

main() {
  debug "Options: ${*}"
  install_roles "${@}"

}

#{{{ Helper functions

install_roles() {
  for role in ${roles}; do
     info "${role}"
     install_role "${role}" "${@}"
  done
}

install_role() {
  local role="${1}"
  shift

  ansible-galaxy install --force "${@}" "${role}"
}

# Usage: info [ARG]...
#
# Prints all arguments on the standard output stream
info() {
  printf "${yellow}>>> %s${reset}\n" "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard output stream
debug() {
  printf "${cyan}### %s${reset}\n" "${*}"
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf "${red}!!! %s${reset}\n" "${*}" 1>&2
}
#}}}

main "${@}"

