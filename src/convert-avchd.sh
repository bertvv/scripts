#!/usr/bin/env bash
#
# Created:  Tue 01 Oct 2013 09:09:17 am CEST
# Modified: Tue 01 Oct 2013 09:14:56 am CEST CEST CEST
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Convert an AVCHD stream (*.MTS) to AVI format.

set -e # abort on nonzero exitstatus
set -u # abort on unbound variable

#--------------------------------------------------------------------------
# Variables
#--------------------------------------------------------------------------

#--------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------

usage() {
cat << _EOF_
Usage: ${0} FILE 
  with FILE the name of a video file (usually *.MTS)
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

if [[ -f "$1" ]]; then
    ffmpeg -i "$1" -vcodec copy -acodec copy avchd.avi
fi
