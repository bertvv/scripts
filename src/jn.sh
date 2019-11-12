#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
#/ Usage: jn [-h|--help]
#/
#/ Launch Jupyter Notebooks Lab in the browser.
#/
#/ OPTIONS
#/   -k, --kill
#/                Kill any running instance of Jupyter
#/   -h, --help
#/                Print this help message
#/
#/ EXAMPLES
#/  jn
#/  jn -k
#/  jn --help
#
# This script depends on the following external commands:
#
# - a web browser
# - gnome-open (libgnome)
# - grep
# - jupyter
# - pgrep (procps-ng)
# - xargs (findutils)

#{{{ Bash settings
# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail
#} }}
# {{{ Variables
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

# Script settings

#}}}

main() {
  process_args "${@}"
  exit_when_jupyter_is_running
  launch_jupyter
}

#{{{ Helper functions

process_args() {
  if [ "$#" -ge 1 ]; then
    case "${1}" in
      -h|--help)
        usage
        exit 0
        ;;
      -k|--kill)
        kill_jupyter
        ;;
      *)
        error "Unrecognized option or argument: ${1}"
        exit 2
        ;;
    esac
  fi
}

kill_jupyter() {
  log "Kill any Jupyter process that's already running"
  local jupyter_pid
  if is_process_running jupyter; then
    jupyter_pid=$(pgrep jupyter)
    debug "Killing process(es) ${jupyter_pid}"
    xargs kill --verbose <<< "${jupyter_pid}"
    sleep 1s
  fi
}

# Usage: is_process_running PROCESS_NAME
#  Returns with exit status 0 if the specified process is running, a nonzero
#  exit status if not.
is_process_running() {
  pgrep "${1}" > /dev/null 2>&1
}

# Usage: exit_when_jupyter_is_running
#  Checks whether Jupyter is running and exits the script if that is the case
exit_when_jupyter_is_running() {
  log "Checking if Jupyter Notebook is already running"
  local jupyter_pid
  if is_process_running jupyter; then
    jupyter_pid=$(pgrep jupyter)
    error "Jupyter Notebook is already running with PID ${jupyter_pid}"
    error "Kill it first or run \"${script_name} -k\""
    exit 1
  fi
}

launch_jupyter() {
  log "Launching Jupyter Notebooks. Keep this terminal open for log messages."
  jupyter notebook &

  # Ensure there is enough time for the service to become available
  sleep 1s

  log "Launching JN Lab web interface in the browser."
  gnome-open https://localhost:8888/lab &
}

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




#}}}

main "${@}"

