#!/bin/bash
#
# Created:  Fri 14 May 2010 09:23:43 AM CEST
# Modified: Sat 12 Jun 2010 10:41:26 PM CEST
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Mirror directories to Tyr.
#

SRC_ROOT=/home/bert
DST_ROOT=www-data@192.168.10.2:/shares/internal/PUBLIC

SRC_DIRS=("Pictures" "Books" "Music" "Videos")
DST_DIRS=("Afbeeldingen" "Bibliotheek" "Audio" "Video")

NUM_DIRS=${#SRC_DIRS[@]}

OPTS='-avuzh'

alert() {
    playsound /usr/share/sounds/ubuntu/stereo/phone-incoming-call.ogg > /dev/null
}

for ((i = 0; i < ${#SRC_DIRS[@]}; i++)); do
    echo "${SRC_DIRS[$i]} -> ${DST_DIRS[$i]}"
    rsync ${OPTS} -e "ssh -l bert" ${SRC_ROOT}/${SRC_DIRS[$i]}/ \
                                   ${DST_ROOT}/${DST_DIRS[$i]}
    alert
done
