#! /usr/bin/bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Rsync-based backup script. Based on a script I got from someone, but the
# original author is unfortunately unknown to me.

#set -o errexit # abort on nonzero exitstatus
#set -o nounset # abort on unbound variable

#{{{ Functions

read_config_file() {
  if [ -r ~/.backup/backup.conf ]; then
    source ~/.backup/backup.conf
    excludefile=~/.backup/exclude.lst
  elif [ -r /etc/backup/backup.conf ]; then
    source /etc/backup/backup.conf
    excludefile=/etc/backup/exclude.lst
  elif [ -r ./backup.conf ]; then
    source ./backup.conf
    excludefile=./exclude.lst
  fi

}

 #}}}
#{{{ Variables

#}}}

# Script proper

read_config_file

