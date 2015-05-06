#! /usr/bin/bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Add Bitbucket repo as a remote, and set the user correctly

set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

#{{{ Functions

usage() {
cat << _EOF_
Usage: ${0} REPO
  with REPO the name of the remote Git repository.
_EOF_
}

#}}}
#{{{ Command line parsing

if [ "$#" -ne "1" ]; then
    echo "Expected 1 argument, got $#" >&2
    usage
    exit 2
fi

#}}}
#{{{ Variables
base_url="git@bitbucket.org"
git_user="bertvanvreckem"
git_email="bert.vanvreckem@hogent.be"
remote_name="origin"
repo_name="${1}"
#}}}

# Script proper
git remote add "${remote_name}" "${base_url}:${git_user}/${repo_name}.git"
git config user.email "${git_email}"


