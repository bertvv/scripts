#! /usr/bin/env python3

import socket
import fcntl
import struct
# from pprint import pprint
from colorama import init, Fore

# Initialise colorama
init(autoreset=True)

# Socket configuration controls, i.e. operations to be passed along with
# ioctl system call. Source: /usr/include/bits/ioctls.h
SIOCGIFADDR = 0x8915   # Get IPv4 address
SIOCGNETMASK = 0x891b  # Get network mask


def get_socket_info(ifname, config_control):
    """Return the results of an `ioctl` system call to get information about a
       network interface, and convert to dotted decimal notation."""

    # Source: http://code.activestate.com/recipes/
    #   439094-get-the-ip-address-associated-with-a-network-inter/
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        addr = socket.inet_ntoa(fcntl.ioctl(
            s.fileno(),
            config_control,
            struct.pack(b'256s', str.encode(ifname[:15])))[20:24])
    except OSError:
        addr = ""
    return addr


def get_ip_address(ifname):
    """Return the IP address of the specified network interface"""
    return get_socket_info(ifname, SIOCGIFADDR)


def get_netmask(ifname):
    """Return the network mask of the specified network interface"""
    return get_socket_info(ifname, SIOCGNETMASK)


def network_interfaces():
    """Return a list of all network interface"""
    return [tup[1] for tup in socket.if_nameindex()]


def get_default_gateway_linux():
    """Read the default gateway directly from /proc."""
    # Source: https://gist.github.com/ssokolow/1059982
    with open("/proc/net/route") as fh:
        for line in fh:
            fields = line.strip().split()
            if fields[1] != '00000000' or not int(fields[3], 16) & 2:
                continue

            return socket.inet_ntoa(struct.pack("<L", int(fields[2], 16)))


def get_name_servers():
    """Return the available name servers"""
    PREFIX = 'nameserver '
    return [line.rstrip().replace(PREFIX, '')
            for line in open('/etc/resolv.conf')
            if PREFIX in line]

print(Fore.YELLOW + 'IP addresses')
print('Iface\tIP address\tNetwork mask')
for iface in network_interfaces():
    print('{0}\t{1}\t{2}'.format(
        iface,
        get_ip_address(iface),
        get_netmask(iface)))

print(Fore.YELLOW + 'Default gateway')
gw = get_default_gateway_linux()
if gw is None:
    print(Fore.RED + 'None')
else:
    print(gw)

print(Fore.YELLOW + 'Name servers')
dns_servers = get_name_servers()

if dns_servers:
    for dns in dns_servers:
        print(dns)
else:
    print(Fore.RED + 'None')
