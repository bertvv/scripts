#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
#/ Usage: wifiqr SSID PASSWORD
#/        wifiqr -h|--help
#/
#/ Generates a QR code that enables mobile devices to connect to a wireless
#/ network specified by its SSID and PASSWORD. The code is saved in a file
#/ «wifi.png» in the current directory.
#/
#/ OPTIONS
#/   -h, --help
#/                Print this help message
#/
#/ EXAMPLES
#/   wifiqr "GUEST_WIFI" "letmeinplz"
#
# Dependencies:
# - qrencode: command line tool that generates QR codes
# - eog: Eye of Gnome, default image viewer in Gnome (can be replaced with
#        any image viewer)
#
# Source: https://twitter.com/nixcraft/status/1211231572298321926


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

ssid=""
password=""

readonly viewer='/usr/bin/eog'
readonly qr_image='wifi.png'
#}}}

main() {
  check_args "${@}"
  generate_wifi_qr "${ssid}" "${password}"

  view_image "${qr_image}"
}

#{{{ Helper functions

# Print usage message on stdout by parsing start of script comments
usage() {
  grep '^#/' "${script_dir}/${script_name}" | sed 's/^#\/\w*//'
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

check_args() {
  case "$#" in
    0)
      error "Not enough arguments"
      usage
      exit 2
      ;;
    1)
      if [ "${1}" = '-h' ] || [ "${1}" = '--help' ]; then
        usage
        exit 0
      else
        error "Not enough arguments"
        usage
        exit 2
      fi
      ;;
    2)
      ssid="${1}"
      password="${2}"
      ;;
    *)
      error "Too many arguments"
      exit 2
  esac
}

# Usage: generate_wifi_qr SSID PASSWORD
generate_wifi_qr() {
  local ssid="${1}"
  local password="${2}"

  qrencode --output=wifi.png \
    --size=10 \
    --dpi=300 \
    "WIFI:T:WPA;S:${ssid};P:${password};;"
}

# Usage: view_image 
view_image() {
  local image="${1}"

  if [ -x "${viewer}" ]; then
    "${viewer}" "${image}" &
  else
    error "Viewer ${viewer} is not an executable program."
  fi
}

#}}}

main "${@}"

