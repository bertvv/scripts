#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
#/ Usage: iso-to-usb ISO_FILE DEVICE
#/
#/ Copies a CDROM/DVD ISO to USB stick, showing progress.
#/
#/ OPTIONS
#/   -h, --help
#/                Print this help message
#/
#/ EXAMPLES
#/  iso-to-usb fedora-livecd.iso /dev/sdc
#
# Dependencies: dd, stat and pv (Pipe Viewer)

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

#}}}

main() {
  check_args "${@}"

  local iso="${1}"
  local destination="${2}"

  info "Copying ${iso} to ${destination}"

  check_mounts "${destination}"
  confirm_copy
  copy_iso_to_usb "${iso}" "${destination}"
}

#{{{ Helper functions

# Usage: check_mounts DEVICE
check_mounts() {
  local device="${1}"

  info "Checking if ${device} is currently mounted"
  mount | grep "${device}"
}

confirm_copy() {
  info "Are you sure you want to continue? [y/N]"
  read -r confirm
  if [ "${confirm}" != 'y' ] && [ "${confirm}" != 'Y' ]; then
    info "Cancelled on user's request"
    exit 0
  fi
}

# Usage: copy_iso_to_usb ISO DEVICE
copy_iso_to_usb() {
  local iso="${1}"
  local iso_size
  local destination="${2}"

  iso_size=$(stat -c '%s' "${iso}")

  debug "Copying ${iso} (${iso_size}B) to ${destination}"

  dd if="${iso}" \
    | pv --size "${iso_size}" \
    | sudo dd of="${destination}"
}

# Print usage message on stdout by parsing start of script comments
usage() {
  grep '^#/' "${script_dir}/${script_name}" | sed 's/^#\/\w*//'
}

# Check if command line arguments are valid
check_args() {
  case "${#}" in
    '1' )     # First, check if help message is requested
      if [ "${1}" = '-h' ] || [ "${1}" = '--help' ]; then
        usage
        exit 0
      fi
      ;;
    '2' ) ;;  # 2 arguments is what's expected
    * )       # All other cases are invalid
      error "Expected 2 arguments, got ${#}"
      usage
      exit 2
      ;;
  esac

  if [ ! -f "${1}" ]; then
    error "First argument should be a file: ${1}"
    exit 1
  fi

  # Check the extension of the source file, should be .iso or .img
  local extension
  extension="$(tr '[:upper:]' '[:lower:]' <<< "${1##*.}")"

  if [ "${extension}" != 'iso' ] && [ "${extension}" != 'img' ]; then
    error "First argument should be an .iso or .img file: ${1}"
  fi

  if [ ! -b "${2}" ]; then
    error "Destination should be a block special file (e.g. /dev/sdc): ${2}"
    exit 1
  fi
}

# Usage: info [ARG]...
#
# Prints all arguments on the standard output stream
info() {
  printf "${yellow}>>> %s${reset}\n" "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard output stream,
# if debug output is enabled
debug() {
  [ "${debug}" != 'on' ] || printf "${cyan}### %s${reset}\n" "${*}"
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf "${red}!!! %s${reset}\n" "${*}" 1>&2
}


#}}}

main "${@}"

