#! /usr/bin/bash
#
# Source: https://gist.github.com/namuol/9122237/
#
# Rage-quit support for Bash

set -e # abort on nonzero exitstatus
set -u # abort on unbound variable

#{{{ Functions

usage() {
cat >&2 <<_EOF_
Usage: ${0} ACTION PROCESS
  Rage-quit all processes with the specified name.

  ACTION is one of
    you   send SIGTERM (-15)
    off   send SIGKILL (-9)
_EOF_
}

flip() {
  perl -C3 -Mutf8 -lpe '$_=reverse;y/a-zA-Z.['\'',({?!\"<_;‿⁅∴\r/ɐqɔpǝɟƃɥıɾʞ|ɯuodbɹsʇnʌʍxʎzɐqɔpǝɟƃɥıɾʞ|ɯuodbɹsʇnʌʍxʎz˙],'\'')}¿¡,>‾؛⁀⁆∵\n/' <<< "$1"
}

#}}}
#{{{ Command line parsing

if [ "$#" -ne "2" ]; then
    echo "Expected 2 arguments, got $#" >&2
    usage
    exit 2
fi

#}}}
#{{{ Variables

people=('(ノಠ-ಠ)ノ彡' '(╯°□°）╯︵' '(ノಠ益ಠ)ノ彡')
person="${people[$RANDOM % ${#people[@]}]}"
action=$1
program=$2

##}}}
## Script proper

case $action in
  you)
    killall "${program}" && (echo ; echo "${person}$(flip "${program}")"; echo)
    ;;
  off)
    killall -9 "${program}" && (echo ; echo "${person}$(flip "${program}") ------ -- -- ╾━╤デ╦︻"; echo)
    ;;
  *)
    echo "Unknown action: ${action}" >&2
    usage
    exit 1
    ;;
esac
