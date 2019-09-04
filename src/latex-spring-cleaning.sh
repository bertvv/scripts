#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
#/ Usage: latex-spring-cleaning [DIR]
#/        latex-spring-cleaning -h|--help
#/
#/ Find directories containing .tex files and clean up all auxilary files.
#/
#/ -h, --help  shows this help message
#/
#/ DIR         the main directory to search recursively. (default: ${HOME})
#/
#/ EXAMPLES
#/
#/  latex-spring-cleaning
#/  latex-spring-cleaning Documents/


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

main_directory="${HOME}"
#}}}

main() {
  check_args "${@}"

  cleanup
}

#{{{ Helper functions

check_args() {
  if [ "$#" -gt 1 ]; then
    error "At most one argument expected (a directory), but got $#"
    usage
    exit 2
  elif [ "$#" -eq 1 ]; then
    if [ "${1}" = '-h' ] || [ "${1}" = '--help' ]; then
      usage
      exit 0
    elif [ ! -d "${1}" ]; then
      error "Not a directory: ${1}"
      exit 1
    elif [ -d "${1}" ]; then
      main_directory="${1}"
    fi
  fi
}

# Usage: cleanup
cleanup() {
  dirlist=$(find "${main_directory}" -type f -name '*.tex' | \
              sed 's/\/[^/]*\.tex$//' | \
              uniq)

  for dir in ${dirlist}; do
    cleanup_dir "${dir}"
  done
}

cleanup_dir() {
  local dir="${1}"

  pushd "${dir}"
  rm -vf ./*.{bak,aux,log,nav,out,snm,ptc,toc,bbl,blg,idx,ilg,ind,tcp,vrb,tps,lof,log,lol,lot,synctex.gz,fls,fdb_latexmk,bcf,run.xml} 2> /dev/null
  rm -vrf _minted* 2> /dev/null # directory for Pygments syntax coloring
  popd
}

# Usage: log [ARG]...
#
# Prints all arguments on the standard output stream
log() {
  printf "${yellow}>>> %s${reset}\\n" "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard output stream,
# if debug output is enabled
debug() {
  [ "${debug}" != 'on' ] || printf "${cyan}### %s${reset}\\n" "${*}"
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf "${red}!!! %s${reset}\\n" "${*}" 1>&2
}

# Print usage message on stdout by parsing start of script comments
usage() {
  grep '^#/' "${script_dir}/${script_name}" | sed 's/^#\/\w*//'
}

#}}}

main "${@}"

