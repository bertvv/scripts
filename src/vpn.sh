#! /bin/bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
# Source: <https://github.com/adrienverge/openfortivpn/issues/867>
#
#/ Usage: SCRIPTNAME [OPTION]
#/
#/ Use openfortivpn to connect to HOGENT's VPN endpoint with SAML login.
#/
#/ The output will show a message like "Authenticate at URL". Control+click
#/ on the URL to open the SAML login page in a web browser.
#/
#/ OPTIONS
#/   -h, --help
#/                Print this help message
#/
#/ EXAMPLES
#/  $ vpn
#/  $ vpn --help
#/
#/ REMARKS
#/
#/ The script asks for superuser access with sudo. You can configure sudo to
#/ allow the command be executed without providing your user password, e.g. by
#/ creating a file /etc/sudoers.d/openfortivpn with content:
#/
#/   Cmnd_Alias  OPENFORTIVPN = /usr/bin/openfortivpn
#/   %wheel      ALL = (ALL) NOPASSWD: OPENFORTIVPN
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
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)
script_name=$(basename "${0}")
script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
readonly script_name script_dir

vpn_endpoint='vpn-ssl.hogent.be'
vpn_port=443

#}}}

main() {
  check_args "${@}"
  sudo openfortivpn "${vpn_endpoint}:${vpn_port}" \
    --saml-login
}

#{{{ Helper functions

check_args() {
  while [ "$#" -gt '0' ]; do
    case "${1}" in
      -h|--help)
        usage
        exit 0
        ;;
      -*)
        printf 'Invalid option: %s\n' "${1}" >&2
        usage
        exit 2
        ;;
      *)
        printf 'This script does not take arguments'
        usage
        exit 2
        ;;
    esac
    shift
  done
}

# Print usage message on stdout by parsing start of script comments
# The comment should start with #/ followed by either a newline or a space
usage() {
  grep '^#/' "${script_dir}/${script_name}" \
    | sed 's/^#\/\($\| \)//' \
    | sed "s/SCRIPTNAME/${script_name}/"
}

#}}}

main "${@}"

