#! /usr/bin/bash
#
# Send output from a command into Gedit, e.g.
#
#    tail /var/log/messages | gedit -
#
# source: @purpleidea https://ttboj.wordpress.com/

{ `/usr/bin/gedit "$@" &> /dev/null`; } < /dev/stdin &
