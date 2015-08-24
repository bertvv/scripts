#!/usr/bin/env bash
#
# Created:  Tue 01 Oct 2013 09:09:17 am CEST
# Modified: Tue 20 May 2014 11:02:46 pm CEST CEST CEST CEST CEST CEST CEST CEST CEST CEST CEST
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Convert an AVCHD stream (*.MTS) to AVI format.

set -o errexit  # abort on nonzero exitstatus
#set -o nounset  # abort on unbound variable

# {{{ Variables
file="${1##*/}"            # Only the file name (without directory)
output_file="${file%.*}"   # strip the extension
echo ${output_file}
# }}}
# {{{ Functions:

usage() {
cat << _EOF_
  Usage: ${0} FILE 
  with FILE the name of a video file (usually *.MTS)
_EOF_
}

# }}}
# {{{ Command line parsing

if [[ "$#" -ne "1" ]]; then
  echo "Expected 1 argument, got $#" >&2
  usage
  exit 2
fi
# }}}
# Script proper

if [[ -f "$1" ]]; then
  ffmpeg -i "$1" \
    -s 1280x720 \
    -vcodec mpeg4 -b:v 15M \
    -acodec libmp3lame -b:a 192k \
    "${output_file}.avi"
fi
