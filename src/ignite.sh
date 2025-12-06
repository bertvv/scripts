#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Script to assist an Ignite talk. PDFs in the current directory starting with
# a number of 2 digits ar shown in order. Every slide is shown 15 seconds.
# Press ENTER between two presentations.
#
# You should install impressive (http://impressive.sourceforge.net/) to run this
# script.

set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

for presentation in [0-9][0-9]*.pdf; do

  echo "Press ENTER to start ${presentation}"
  read

  impressive --nologo \
    -a 15 \
    --page-progress \
    --fade \
    --autoquit \
    "${presentation}"
done
