#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# PURPOSE
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
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)
readonly SCRIPT_NAME=$(basename "${0}")
readonly JABREF_HOME="${HOME}/opt"
#}}}



main() {
  check_args "${@}"
  jabref_latest "${@}"

}

#{{{ Helper functions

check_args() {
  if [ "${#}" -ge 1 ]; then
    if [ "${1}" = "-h" -o "${1}" = "--help" ]; then
      usage
      exit 0
    fi
  fi
}

# Print usage message on stdout
usage() {
cat << _EOF_
Usage: ${SCRIPT_NAME} [OPTIONS]... [ARGS]...

  Runs the latest version of Jabref installed in ${JABREF_HOME}

OPTIONS:

  -h, --help   Prints this help message

Arguments are passed to JabRef verbatim.
_EOF_
}

jabref_latest() {
  local jabref_versions=(${JABREF_HOME}/JabRef*.jar)
  local latest_version="${jabref_versions[-1]}"

  printf "%s\n" "${latest_version}"
  # Run the Jar in the background and print its PID
  java -jar "${latest_version}" "${@}" & echo $!
}

#}}}

main "${@}"

