#! /usr/bin/bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Initialise an Ansible project, based on 
# https://github.com/bertvv/ansible-skeleton/

set -e # abort on nonzero exitstatus
set -u # abort on unbound variable

#{{{ Variables

#}}}
#{{{ Functions

usage() {
cat << _EOF_
Usage: ${0} PROJECT_NAME
_EOF_
}

#}}}
#{{{ Command line parsing

if [ "$#" -ne "1" ]; then
    echo "Expected 1 argument, got $#" >&2
    usage
    exit 2
fi

project="$1"

if [ -d "${project}" ]; then
  echo "Project directory ${project} already exists. Bailing out." >&2
  exit 1
fi

#}}}
# Script proper

wget https://github.com/bertvv/ansible-skeleton/archive/master.zip
unzip master.zip
mv ansible-skeleton-master "${project}"
git init "${project}"
cd "${project}"
git add .
git commit --message "Initial commit, Ansible skeleton"
