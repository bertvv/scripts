#!/bin/bash
#
# Created:  Tue 19 Feb 2013 12:23:20 AM CET
# Modified: Sun 13 Oct 2013 09:01:33 pm CEST CEST CEST CEST
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Screencast with avconv (ffmpeg)
# Credits: a.o. http://ffmpeg.org/trac/ffmpeg/wiki/x264EncodingGuide

set -e # abort on nonzero exitstatus
set -u # abort on unbound variable

# output directory
DIR=${HOME}/Videos/screencast
# file, without extension
FILE=record
# output type
EXT=mkv
# Size
#VIDEO_SIZE="800x600"  # nice for capturing terminal demo
VIDEO_SIZE="1366x768" # entire screen 
# Offset
#AREA=":0.0+52,24"   # nice for capturing terminal demo
AREA="${DISPLAY}.0+0.0"     # entire screen

if [[ ! -d "${DIR}" ]]; then
    mkdir -p "${DIR}"
fi

i=1
OUT="${DIR}/${FILE}-$(printf "%03d" ${i}).${EXT}"
while [[ -f "${OUT}" ]]; do
    let i++
    OUT="${DIR}/${FILE}-$(printf "%03d" ${i}).${EXT}"
done

ffmpeg -xerror -loglevel info \
    -f alsa -ac 2 -ar 48000 -i pulse \
    -f x11grab -video_size "${VIDEO_SIZE}" -i "${AREA}" \
    -vcodec libx264 -r 30 \
    -metadata author="Bert Van Vreckem" \
    -metadata copyright="CC-BY-SA" \
    -metadata year="$(date +%Y)" \
    -metadata date="$(date +%Y-%m-%d)" \
    -metadata creation_time="$(date +%Y-%m-%dT%T)" \
    -n "${OUT}"
