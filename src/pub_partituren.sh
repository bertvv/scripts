#!/bin/bash
#
# Created:  Tue 06 Apr 2010 07:16:09 PM CEST
# Modified: Tue 06 Apr 2010 07:30:07 PM CEST
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#

src_dir=~/Documents/Music
dest_dir=~/Dropbox/Public/Partituren

rsync_opts="-avz --delete"

rsync ${rsync_opts} ${src_dir}/transcriptions/dist/ ${dest_dir}/bert
rsync ${rsync_opts} ${src_dir}/partituren/volksdans/ ${dest_dir}/scan


