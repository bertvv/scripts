#! /bin/bash
#
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
EXT=mp4
# Get screen dimensions of primary display
VIDEO_SIZE=$(xrandr | awk '/ connected.*\+0\+0/ {print $4;}' | sed 's/+0+0//')
# Offset
#AREA=":0.0+52,24"   # nice for capturing terminal demo
AREA="${DISPLAY}.0+0.0"     # entire screen

if [[ ! -d "${DIR}" ]]; then
    mkdir -p "${DIR}"
fi

i=1
OUT="${DIR}/${FILE}-$(printf "%03d" ${i}).${EXT}"
while [[ -f "${OUT}" ]]; do
    (( i++ ))
    OUT="${DIR}/${FILE}-$(printf "%03d" ${i}).${EXT}"
done

ffmpeg -xerror -loglevel info \
    -f pulse -ac 2 -ar 48000 -i default \
    -f x11grab -video_size "${VIDEO_SIZE}" -i "${AREA}" \
    -vcodec libx264 -r 30 \
    -codec:a aac \
    -metadata author="Bert Van Vreckem" \
    -metadata copyright="CC-BY-SA" \
    -metadata year="$(date +%Y)" \
    -metadata date="$(date +%Y-%m-%d)" \
    -metadata creation_time="$(date +%Y-%m-%dT%T)" \
    -r 60000/1001 -async 1 -vsync 1 \
    -n "${OUT}"
