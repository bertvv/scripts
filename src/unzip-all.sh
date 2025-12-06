#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
#/ Usage: unzip-all [OPTIONS]... [DIR]
#/
#/ In a directory with a lot of zip archives, unzip them all in a subdir with
#/ the same name as the archive.
#/
#/ OPTIONS
#/   -h, --help
#/                Print this help message
#/   -d, --delete
#/                Delete archives afterwards
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
script_name=$(basename "${0}")
script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly script_name script_dir
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

# Debug info ('on' to enable)
readonly debug="${DEBUG:-off}"

# Extra options to be passed to unzip
unzip_options=

# If 'y', delete archives, if 'n' leave them be
delete_archive=n

# List of directories to process (will be set to PWD if none were passed as
# an argument)
directories=''
#}}}

main() {
  check_args "${@}"
  process_directories
}

#{{{ Helper functions

process_directories() {
  for d in ${directories}; do
    unpack_archives "${d}"
  done
}

# Usage: unpack_archives DIR
#   For each archive in DIR, create a directory with the same name and unpack
#   it in that subdir
unpack_archives() {
  local dir="${1}"
  pushd "${dir}" > /dev/null
  log "Processing directory ${dir}"

  for archive in *.zip; do
    local dirname=${archive%%.zip}

    debug "creating ${dirname}"
    mkdir -p "${dirname}"

    unpack_zip_archive "${archive}" "${dirname}"

    if [ "${delete_archive}" = 'y' ]; then
      debug "Removing ${archive}"
      rm "${archive}"
    fi
  done

  popd > /dev/null
}

# Usage: unpack_zip_archive ARCHIVE DIR
unpack_zip_archive() {
  local archive="${1}"
  local dirname="${2}"

  if [ -n "${unzip_options}" ]; then
    unzip -o "${unzip_options}" "${archive}" -d "${dirname}"
  else
    unzip -o "${archive}" -d "${dirname}"
  fi
}

# Usage: check_args "${@}"
#   Process command line arguments
check_args() {
  while [ "${#}" -gt '0' ]; do
    case "${1}" in
      -d|--delete)
        delete_archive=y
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      -v|--verbose)
        unzip_options="${unzip_options} -v"
        shift
        ;;
      -*)
        error "Unknown option: ${1}"
        usage
        exit 1
        ;;
      *)
        directories="${directories}	${1}"
        shift
        ;;
    esac
  done

  if [ -z "${directories}" ]; then
    directories="${PWD}"
  fi
}

# Print usage message on stdout by parsing start of script comments
usage() {
  grep '^#/' "${script_dir}/${script_name}" | sed 's/^#\/\($\| \)//'
}

# Usage: log [ARG]...
#
# Prints all arguments on the standard output stream
log() {
  printf '\e[0;33m>>> %s\e[0m\n' "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard output stream,
# if debug output is enabled
debug() {
  [ "${debug}" != 'on' ] || printf '\e[0;36m### %s\e[0m\n' "${*}"
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf '\e[0;31m!!! %s\e[0m\n' "${*}" 1>&2
}


#}}}

main "${@}"

