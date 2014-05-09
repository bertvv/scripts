#!/bin/bash
#
# Created:  Tue 19 Mar 2013 10:05:13 AM CET
# Modified: Tue 19 Mar 2013 10:07:41 AM CET
#
# Source: http://ubuntuforums.org/showthread.php?t=1658648

echo "Current Linux Kernel version: $(uname -r)"

dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get purge
