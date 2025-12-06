#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
#/ Usage: SCRIPTNAME [OPTIONS]... [ARGUMENTS]...
#/
#/ 
#/ OPTIONS
#/   -h, --help
#/                Print this help message
#/
#/ EXAMPLES
#/  


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

#}}}

main() {
  # check_args "${@}"
  for f in "${@}"; do

    printf '%s ' "${f}"
    pdf2txt "${f}" \
      | tr ' ' '\n' | tr -d '.)(,;:!?-' \
      | sort | uniq \
      | grep -v '\(/\|@\|#\|_\|%\|&\)' \
      | awk '{ print length(), $0 | "sort -n" }' \
      | tail -1
  done
}

#{{{ Helper functions



#}}}

main "${@}"

