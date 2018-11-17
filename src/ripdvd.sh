#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
#/ Usage: ripdvd ISO_FILE
#/
#/ Creates an ISO copy of a DVD.


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

# DVD device
readonly dvd_device='/dev/sr0'
#}}}

main() {
  check_args "${@}"

  local iso_image="${1}"
  create_iso "${iso_image}"
  check_image "${iso_image}"
}

#{{{ Helper functions

check_args() {
  if [ "$#" -ne '1' ]; then
    error "Expected 1 argument, but got: $#"
    usage
    exit 1
  fi
}

create_iso() {
  local iso_image="${1}"
  local dvd_info block_size volume_size total_size

  # Read info on the DVD
  dvd_info=$(isoinfo -d -i "${dvd_device}")

  # Parse output of isoinfo and get block size and volume size
  block_size=$(grep "^Logical block" <<< "${dvd_info}" | awk '{ print $5 }')
  volume_size=$(grep "^Volume size" <<< "${dvd_info}" | awk '{ print $4 }')
  total_size=$(( "${block_size}" * "${volume_size}" ))

  # Use dd to create an ISO image with the found block and volume size
  dd if="${dvd_device}" bs="${block_size}" count="${volume_size}" | \
    pv --progress --timer --eta --bytes --rate --size "${total_size}" | \
    dd of="${iso_image}" bs="${block_size}"
}

check_image() {
  local iso_image="${1}"
  local orig_check copy_check

  info "Comparing checksums..."
  orig_check=$(sha1sum "${dvd_device}" | awk '{ print $1 }')
  info "Checksum original: ${orig_check}"

  copy_check=$(sha1sum "${iso_image}" | awk '{ print $1 }')
  info "Checksum copy    : ${copy_check}"

  if [ "${orig_check}" != "${copy_check}" ]; then
    error "Checksums do not match! Copy failed."
    exit 2
  else
    info "Checksums match, copy succeeded!"
  fi
}

# Usage: info [ARG]...
#
# Prints all arguments on the standard output stream
info() {
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

