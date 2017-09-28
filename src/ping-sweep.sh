#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Perform a ping sweep on the specified class C network

set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

#{{{ Functions

usage() {
cat << _EOF_
Usage: ${0} NETWORK

  NETWORK  the network part of a class C IP address, e.g. 192.168.1

_EOF_
}

# Usage: host_is_up IP
# with IP a (full) IP address. Returns exit status 0 if the specified host
# replies to the tweet, a nonzero exit status otherwise.
host_is_up() {
  # Send one ping (-c) and wait at most 1 second (-w)
  ping -c 1 -w 1 "${ip}" > /dev/null 2>&1
}

#}}}
#{{{ Command line parsing

if [ "$#" -ne "1" ]; then
    echo "Expected 1 argument, got $#" >&2
    usage
    exit 2
fi

#}}}
#{{{ Variables

network="${1}"

#}}}

# Script proper

for host in $(seq 1 254); do

  ip="${network}.${host}"

  if host_is_up "${ip}"; then
    echo "${ip}"
  fi

done
