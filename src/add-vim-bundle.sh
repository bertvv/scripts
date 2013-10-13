#!/bin/bash -
#
# Created:  Wed 17 Apr 2013 10:02:36 AM CEST
# Modified: Mon 13 May 2013 11:40:11 AM CEST
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#

set -e # abort on nonzero exitstatus
set -u # abort on unbound variable

dir=${PWD}
bundles=.vim/bundle

function help() {
cat << EOF
$(basename $0) GIT_REPO
  installs the Vim plugin from a Git repository into ${bundles}.
EOF
}

if [[ $# -ne 1 ]]; then
    echo "Wrong number of arguments. Expected 1, got $#." >&2
    help
    exit 2
fi

if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
    help
    exit 0
fi

repo="${1}"
repo_name=${repo##*/}           # Strip git://github.com/user/
bundle_name=${repo_name%%.git}  # Strip .git

if [[ ! -d "${bundles}/${bundle_name}" ]]; then
    cd
    git submodule add -f "${repo}" "${bundles}/${bundle_name}"
#    git commit -a -m "Installed bundle ${bundle_name} from ${repo}"
    cd "${dir}"
else
    echo "Submodule with this name already exists: ${bundle_name}" >&2
    exit 1
fi

