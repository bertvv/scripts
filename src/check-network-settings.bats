#! /usr/bin/env bats
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>

external_site='icanhazip.com'

@test 'Host should have at least one valid IPv4 address' {

  # Get the IPv4 addresses, and filter out the loopback address
  # and zeroconf addresses.
  ipv4_addresses=$(ip a \
    | grep 'inet[^6]' \
    | awk '{print $2}' \
    | grep --invert-match --fixed-strings '127.0.0.1' \
    | grep --invert-match '196\.254' )

  printf "IPv4 addresses:\n%s\n" "${ipv4_addresses}"

  # The resulting list should not be empty
  [ -n "${ipv4_addresses}" ]
}

@test 'Host should have a default gateway' {
  # Get the default route from the routing table
  default_route=$(ip r | grep 'default via')

  printf "Default route:\n%s\n" "${default_route}"

  # The result should be nonempty
  [ -n "${default_route}" ]
}

@test 'Host should have a DNS server' {
  # Get the nameservers listed in /etc/resolv.conf
  name_servers=$(grep 'nameserver' /etc/resolv.conf)

  printf "Nameservers:\n%s\n" "${name_servers}"

  # The result should be nonempty
  [ -n "${name_servers}" ]
}

@test 'Default DNS server should respond to queries' {
  run getent ahosts "${external_site}"

  [ "${status}" -eq '0' ]
  [ -n "${output}" ]
}

# Remark that the command dig should be installed for the following test
@test 'All DNS servers should respond to queries' {
  name_servers=$(grep '^nameserver' /etc/resolv.conf \
    | awk '{print $2}')

  for name_server in ${name_servers}; do
    dig "@${name_server}" "${external_site}" +short
  done
}
