#! /usr/bin/env bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Read an Audio CD and create an image using cdrdao

# {{{Preamble
set -e # abort on nonzero exitstatus
set -u # abort on unbound variable

# {{{ Functions

usage() {
cat << _EOF_
Usage: ${0} TITLE
  Reads an audio cd in disc-at-once mode using cdrdao and creates an image file
  and associated table of contents with the specified TITLE. Spaces in the
  title will be replaced with underscores.
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

title="${1// /_}"

#}}}
# }}}

# Script proper

cdrdao read-cd --with-cddb --datafile "${title}".img "${title}".toc
eject
