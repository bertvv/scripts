#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
#/ Usage: find-file-versions FILENAME [DIR]
#/
#/   Searches for the specified files in the specified directory (or the user's
#/ home). The script will compare all files and show which are identical and
#/ which are different (according to their SHA1 checksum).
#/
#/ OPTIONS
#/   -h, --help
#/                Print this help message
#/
#/ EXAMPLES
#/  find-file-versions Vagrantfile ~/vagrant
#/    search for different versions of "Vagrantfile" in ~/vagrant
#/  find-file-versions .gitattributes
#/    search for different versions of .gitattributes in the user's home directory


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
# Debug info ('on' to enable)
readonly debug='on'

search_dir="${HOME}"
file_name=""

#}}}

main() {
  check_args "${@}"

  find_files \
    | calculate_checksums \
    | sort \
    | organize_versions
}

#{{{ Helper functions

# Print usage message on stdout by parsing start of script comments
usage() {
  grep '^#/' "${script_dir}/${script_name}" | sed 's/^#\/\w*//'
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf "${red}!!! %s${reset}\\n" "${*}" 1>&2
}


check_args() {
  if [ "${#}" -lt "1" ]; then
    error "Not enough arguments: expected at least one, got ${#}."
    usage
    exit 1
  fi

  if [ "${1}" = "-h" ] || [ "${1}" = "--help" ]; then
    usage
    exit 0
  fi

  file_name="${1}"

  if [ -n "${2}" ]; then
    search_dir="${2}"
  fi
}

find_files() {
  find "${search_dir}" -type f -name "${file_name}"
}

calculate_checksums() {
  xargs sha1sum
}

organize_versions() {
  local current_checksum=''

  while read -r line; do
    local checksum="${line%% *}"
    local file="${line##* }"

    if [ "${checksum}" != "${current_checksum}" ]; then
      printf "${yellow}%s${reset}\\n" "${checksum}"
      current_checksum="${checksum}"
    fi

    printf "${cyan}%s${reset}\\n" "${file}"
  done
}

#}}}

main "${@}"

