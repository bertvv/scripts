#! /bin/bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
# See: <https://github.com/adrienverge/openfortivpn/issues/867>
#
#/ Usage: SCRIPTNAME [COMMAND]
#/
#/ Use openfortivpn to connect to HOGENT's VPN endpoint with SAML login.
#/
#/ COMMANDS
#/
#/   help, -h, --help
#/                  Print this help message
#/   info, status
#/                  Print status of the VPN connection
#/                  (default action)
#/   on, true, 1
#/                  Connect to the VPN endpoint
#/   off, false, 0
#/                  Disconnect from the VPN endpoint
#/   check, deps
#/                  Check whether necessary commands are installed
#/ 
#/ Commands (except on, off) can be abbreviated, e.g. c or ch instead of check.
#/
#/ EXAMPLES
#/
#/  $ SCRIPTNAME           Shows VPN status
#/  $ SCRIPTNAME on        Connect VPN
#/  $ SCRIPTNAME 0         Disconnect VPN
#/  $ SCRIPTNAME --help    Print this help message
#/  $ SCRIPTNAME c         Check dependencies
#/
#/ REMARKS
#/
#/ The script asks for superuser access with sudo. You can configure sudo to
#/ allow the command be executed without providing your user password, e.g. by
#/ creating a file /etc/sudoers.d/openfortivpn with content:
#/
#/   %wheel      ALL = (ALL) NOPASSWD: /usr/bin/openfortivpn
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
  if [ "$#" -eq '0' ]; then

    show_vpn_status
    exit 0

  elif [ "$#" -eq '1' ]; then

    case "${1}" in
      h|he|hel|help|-h|--help)
        usage
        ;;
      on|true|1)
        activate_vpn
        ;;
      off|false|0)
        deactivate_vpn
        ;;
      i|in|inf|info|s|st|sta|stat|statu|status)
        show_vpn_status
        ;;
      c|ch|che|chec|check|d|de|dep|deps)
        check_dependencies
        ;;
      *)
        printf '🔥 \e[0;31mInvalid option or argument: %s\e[0m\n' "${1}" >&2
        usage
        exit 2
        ;;
    esac

  else

    printf '🔥 \e[0;31mAt most 1 argument expected, but got %d!\e[0m\n' "$#"
    exit 2

  fi
}

#{{{ Helper functions

# Usage: activate_vpn
#  Starts the VPN tunnel and opens a browser window for the SAML authentication
activate_vpn() {
    printf '🌐 \e[0;32mActivating VPN connection.\e[0m\n'
    sudo openfortivpn "${vpn_endpoint}:${vpn_port}" \
      --saml-login &
    xdg-open "https://${vpn_endpoint}:${vpn_port}/remote/saml/start?redirect=1" &
}

# Usage: deactivate_vpn
#  Shuts down the VPN tunnel
deactivate_vpn() {
  local vpn_pid
  vpn_pid=$(pgrep --full 'sudo openfortivpn' || true)

  if [ -n "${vpn_pid}" ]; then
    printf '🛑 \e[0;34mStopping VPN connection.\e[0m\n'
    sudo pkill --full 'sudo openfortivpn'
  else
    printf '🛑 \e[0;34mVPN connection does not seem to be active.\e[0m\n'
  fi
}

# Usage: show_vpn_status
#  Show information about the VPN tunnel: process, IP, DNS
show_vpn_status() {
  local vpn_pid
  vpn_pid=$(pgrep --oldest --full 'sudo openfortivpn' || true)

  if [ -z "${vpn_pid}" ]; then
    printf 'ℹ️ \e[0;33mVPN connection does not seem to be active.\e[0m\n'
    printf '\nEnable VPN with command: %s on\n' "${script_name}"
    return
  fi

  printf 'ℹ️ \e[0;32mProcess info:\e[0m\n'
  pstree --arguments --compact-not --show-pids "${vpn_pid}"
  
  printf 'ℹ️ \e[0;32mIP:\e[0m\n'
  ip address show dev ppp0

  printf 'ℹ️ \e[0;32mDNS:\e[0m\n'
  resolvectl dns ppp0
}

# Usage: check_dependencies
#   Checks whether all commands that are not installed by default are present.
check_dependencies() {
  local commands=(ip openfortivpn pgrep pkill pstree resolvectl xdg-open)
  local success=true

  printf 'ℹ️ \e[0;34mChecking dependencies:\e[0m\n'

  for cmd in "${commands[@]}"; do
    printf '%-30s' "${cmd}"
    if which "${cmd}" &> /dev/null; then
      printf '[ \e[0;32mOK\e[0m ]\n'
    else
      printf '[\e[0;31mFAIL\e[0m]\n'
      success=false
    fi
  done

  if [ "${success}" = 'true' ]; then
    printf '✅ \e[0;32mAll commands are present!\e[0m\n'
  else
    printf '🔥 \e[0;31mOne or more commands missing, ensure you have them installed!\e[0m\n'
  fi

  # Check openfortivpn version (should be >= 1.23.0)
  local minor_version
  minor_version=$(openfortivpn --version | cut -d. -f2)
  
  printf 'openfortivpn version: %-8s' "$(openfortivpn --version)"
  if [ "${minor_version}" -ge '23' ]; then
    printf '[ \e[0;32mOK\e[0m ]\n'
  else
    printf '[\e[0;31mFAIL\e[0m]\n'
    printf '🔥 \e[0;31mMinimal required version is 1.23.0\e[0m\n'
    printf '   \e[0;31mYour version of openfortivpn doesn'\''t support SAML login!\e[0m\n'
    printf '   See <https://github.com/adrienverge/openfortivpn/blob/master/CHANGELOG.md#1230>\n'
  fi
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

