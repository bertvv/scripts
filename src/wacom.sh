#! /bin/bash
#
# Source: User bebop on askubuntu.com:
# <https://askubuntu.com/questions/839161/limit-a-graphics-tablet-to-one-monitor>
#
#/ Usage: SCRIPTNAME [OPTIONS]... [ARGUMENTS]...
#/
#/ 
#/ OPTIONS
#/   -h, --help
#/                Print this help message
#/
#/ EXAMPLES
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
readonly script_name=$(basename "${0}")
readonly script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

# Name of the screen (find using xrandr)
monitor="eDP-1"

# Name of your drawing tablet (find using xinput)
pad_name="Wacom One by Wacom S Pen stylus"

# Numeric ID of the stylus
stylus_id=$(xinput | grep "Pen stylus" | cut -f 2 | cut -c 4-5)
#}}}

main() {
  # Restricts the Wacom tablet stylus to the main monitor
  xinput map-to-output "${stylus_id}" "${monitor}"
}

#{{{ Helper functions



#}}}

main "${@}"

