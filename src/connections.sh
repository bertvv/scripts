#! /usr/bin/bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Give a list of all open connections, consisting of IP address and host name
# (if reverse DNS lookup succeeds).

set -e # abort on nonzero exitstatus
set -u # abort on unbound variable

 #{{{ Variables

#}}}
# {{{ Functions

usage() {
cat << _EOF_
Usage: ${0} [-h|--help]
  Print a list of hosts with an open TCP connection, consisting of their IP
  address and host name (if a reverse DNS lookup succeeds).
_EOF_
}

# List all hosts with an active TCP connection
active_hosts() {
  netstat -tn4 | awk '/ESTABLISHED/ {print $5}' | strip_port | sort -n | uniq
}

# Strips the port number from a string of the form IP_ADDRESS:PORT
strip_port() {
  sed 's/:.*$//'
}

# Perform a reverse DNS lookup, only returning the host name
reverse_lookup() {
  dig -x "$1" +short | head -1
}

# Use whois to find out the network name
network_name() {
  whois "$1" | grep -i netname | head -1 | awk '{print $2}'
}

print_host_info() {
  local ip=$1
  local host=$(reverse_lookup "${ip}")
  local netname=$(network_name "${ip}")

  printf "%16s %20s %s\n"  "${ip}" "${netname}" "${host}"
}

 #}}}
#{{{ Command line parsing

if [[ "$#" -ge "1" ]]; then
    case $1 in
      -h|--help)
        usage
        exit 0
        ;;
      *)
        echo "Invalid option/argument" >&2
        usage
        exit 2
        ;;
    esac
fi

#}}}
# Script proper

for ip in $(active_hosts); do
  print_host_info "${ip}"
done
