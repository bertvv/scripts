#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Clone a Bitbucket repo, and set the user correctly

set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

#{{{ Functions

usage() {
cat << _EOF_
Usage: ${0} REPO [DIR]
  with REPO the name of the remote Git repository.

  Clones the specified repo
_EOF_
}

#}}}
#{{{ Command line parsing

if [ "$#" -lt "1" -a "$#" -gt 2 ]; then
    echo "Expected 1 or 2 arguments, got $#" >&2
    usage
    exit 2
fi

#}}}
#{{{ Variables

base_url="git@bitbucket.org"
git_user="bertvanvreckem"
git_email="bert.vanvreckem@hogent.be"
repo_name="${1}"
target_dir="${repo_name}"
if [ "$#" -eq "2" ]; then
  target_dir="$2"
fi

#}}}

# Script proper
git clone --config user.email="${git_email}" "${base_url}:${git_user}/${repo_name}.git" "${target_dir}"
