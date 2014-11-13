#! /usr/bin/bash
#
# Source: https://gist.github.com/namuol/9122237/
#
# Rage-quit support for Bash
#
# {{{ Preamble

set -u # abort on unbound variable

# {{{ Functions

# Print usage message
usage() {
cat >&2 <<_EOF_
Usage: ${0} ACTION PROCESS
  Rage-quit all processes with the specified name.

  ACTION is one of
    you   send SIGTERM (-15)
    off   send SIGKILL (-9)
_EOF_
}

# Print the specified message upside down
# Parameters:
#   $1 -- a string
flip() {
  perl -C3 -Mutf8 -lpe '$_=reverse;y/a-zA-Z1234567890.['\'',({?!\"<_;‿⁅∴\r/ɐqɔpǝɟƃɥıɾʞ|ɯuodbɹsʇnʌʍxʎzɐqɔpǝɟƃɥıɾʞ|ɯuodbɹsʇnʌʍxʎz⇂zƐㄣϛ9ㄥ860˙],'\'')}¿¡,>‾؛⁀⁆∵\n/' <<< "$1"
}

# Print message when killing the process(es) fails
fail_msg() {
  local messages=("(；￣Д￣)" "┬─┬ ︵ /(.□. \）" "y=ｰ( ﾟдﾟ)･∵." "(；⌣̀_⌣́)")
  local message="${messages[$RANDOM % ${#messages[@]}]}"

  echo ; echo "${message} . o O ( That didn’t work )"; echo
}

# Print message when killing the specified process(es) succeeds
# Parameters:
#   $1 -- the name of the process that was killed
success_msg() {
  faces=('(ノಠ-ಠ)ノ彡' '(╯°□°）╯︵' '(ノಠ益ಠ)ノ彡' '(ノ ゜Д゜)ノ ︵' '(ﾉಥДಥ)ﾉ︵' ' ヽ(`Д´)ﾉ︵')
  face="${faces[$RANDOM % ${#faces[@]}]}"

  echo ; echo "${face}$(flip "${program}")"; echo
}

# }}}
# {{{ Command line parsing

if [ "$#" -ne "2" ]; then
    echo "┬─┬ ノ( ゜-゜ノ) patience young grasshopper" >&2
    usage
    exit 2
fi

# }}}
# {{{ Variables

action=$1
program=$2

case ${action} in
  you)
    sig="-9"
    ;;
  off)
    sig="-15"
    ;;
  *)
    echo "Unknown action: ${action}" >&2
    usage
    exit 1
    ;;
esac

# }}}
# }}}

## Script proper

pkill "${sig}" "${program}"
exit_status=$?

if [ "${exit_status}" -eq "0" ]; then
  success_msg "${program}"
else
  fail_msg "${program}"
  exit ${exit_status}
fi
