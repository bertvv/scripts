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
dependencies=(dd pv stat)

# Debug info ('on' to enable)
readonly debug='on'

#}}}

main() {
  check_dependencies
  check_args "${@}"

  local iso="${1}"
  local destination="${2}"

  log "Copying ${iso} to ${destination}"

  check_mounts "${destination}"
  confirm_copy
  copy_iso_to_usb "${iso}" "${destination}"
}

#{{{ Helper functions

check_dependencies() {
  debug "Checking dependencies"
  for dep in "${dependencies[@]}"; do
    check_command_exists "${dep}"
  done
}

# Usage: check_command_exists COMMAND
check_command_exists() {
  local command="${1}"
  if ! command -v "${command}" > /dev/null 2>&1; then
    error "Command ${command} is needed but not available, please install it first. Bailing out."
    exit 1
  fi
}

# Usage: check_mounts DEVICE
check_mounts() {
  local device="${1}"

  log "Checking if ${device} is currently mounted"

  if grep "${device}" /proc/mounts > /dev/null 2>&1; then
    error "Device ${device} is mounted, bailing out"
    exit 1
  fi
}

confirm_copy() {
  log "Are you sure you want to continue? [y/N]"
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

