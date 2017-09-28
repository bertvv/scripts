#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Delete VirtualBox Host-only network interfaces.

set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

#{{{ Variables
min=1
#}}}

#{{{ Functions

usage() {
cat << _EOF_
Usage: ${0} [OPTION] [MIN]

  Removes all VirtualBox Host-Only interfaces, starting with the interfaced
  numbered [MIN]. Default value is 1, leaving vboxnet0 untouched.

OPTIONS

  -h, --help  Print this help message

_EOF_
}

#}}}
#{{{ Command line parsing

if [ "$#" -gt "1" ]; then
  echo "Expected at most 1 argument, got $#" >&2
  exit 2
fi
if [ "$#" -eq "1" ]; then
  if [ "$1" = "-h" -o "$1" = "--help" ]; then
    usage
    exit 0
  else
    min=$1
  fi
fi

#}}}
# Script proper

while vboxmanage hostonlyif remove "vboxnet${min}" > /dev/null 2>&1
do
  (( min = min + 1 ))
done
