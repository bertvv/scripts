#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Find git repositories with local changes.

set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

#{{{ Functions

# Show repository status
# $1 - the path to a .git repository
# $2 - verbosity (0 or 1). If 1, the status of clean repos is shown, if 0
#      only ‘dirty’ repos are shown.
repo_status() {
  cd "${1}/.."
  if [ -n "$(git status --short)" ]; then
    echo -e "${IRed}x ${PWD}${Reset}" >&2
    num_dirty=$(( num_dirty + 1 ))
  else
    if [ "${2}" -ne "0" ]; then
      echo -e "${IGreen}v${Reset} ${PWD}"
    fi
  fi
}

#}}}
#{{{ Command line arguments

verbose=0
if [ "$#" -gt "0" ]; then
  if [ "$1" = '-v' -o "$1" = '--verbose' ]; then
    echo "verbose"
    export verbose=1
  fi
fi

#}}}
#{{{ Variables

IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
Reset='\e[0m'       # Text Reset

top_dir="${HOME}"
repos=$(find "${top_dir}" -type d -name '.git')
num_dirty=0

IFS=$'\n'

#}}}

#
# Script proper
#
for repo in ${repos}; do
  repo_status "${repo}" "${verbose}"
done
echo "${num_dirty} repos with local changes"
