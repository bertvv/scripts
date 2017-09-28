#! /usr/bin/env bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Burn audio cd image to disk

set -e # abort on nonzero exitstatus
set -u # abort on unbound variable

#{{{ Functions

usage() {
cat << _EOF_
Usage: ${0} TOCFILE
  Burn an audio image to CD, identified by the given TOC file
_EOF_
}

#}}}
#{{{ Command line parsing

if [[ "$#" -ne "1" ]]; then
    echo "Expected 1 argument, got $#" >&2
    usage
    exit 2
fi

#}}}
#{{{ Variables

toc="$1"

#}}}
# Script proper

sudo cdrdao write --eject --driver generic-mmc-raw "${toc}"
