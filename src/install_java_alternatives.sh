#!/usr/bin/env bash
#
# Created:  Thu 20 Jun 2013 09:49:05 PM CEST
# Modified: Thu 20 Jun 2013 11:26:46 PM CEST
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Install links for Java binaries to be used by update-alternatives

set -e # abort on nonzero exitstatus
set -u # abort on unbound variable

#--------------------------------------------------------------------------
# Variables
#--------------------------------------------------------------------------

JDK_BINARIES="java javaws javac jar"
PRIORITY=200000

#--------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------

usage() {
cat << _EOF_
Usage: ${0} DIR
  with DIR the top level directory of a Java SDK, e.g.
  /usr/java/jdk1.7.0_25/
_EOF_
}

#--------------------------------------------------------------------------
# Command line parsing
#--------------------------------------------------------------------------

if [[ "$#" -ne "1" ]]; then
    echo "Expected 1 argument, got $#" >&2
    usage
    exit 2
fi

#--------------------------------------------------------------------------
# Script proper
#--------------------------------------------------------------------------
if [[ ! -d "${1}" ]]; then
    echo "Not a directory: ${1}" >&2
    exit 2
fi

for binary in ${JDK_BINARIES}; do
    cur="${1}/bin/${binary}"
    echo $cur
    if [[ -x "${cur}" ]]; then
        sudo alternatives --install /usr/bin/${binary} ${binary} \
            "${cur}" ${PRIORITY}
    else
        echo "Skipping ${cur}: not an executable" >&2
    fi
done

java_plugin="${1}/jre/lib/amd64/libnpjp2.so"

if [[ -f "${java_plugin}" ]]; then
    sudo alternatives --install /usr/lib64/mozilla/plugins/libjavaplugin.so \
        libjavaplugin.so.x86_64 "${java_plugin}" ${PRIORITY}
fi
set +x
