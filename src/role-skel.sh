#! /usr/bin/bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Set up scaffolding for an Ansible role

set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

#{{{ Functions

usage() {
cat << _EOF_
Usage: ${0} ROLENAME
  with ROLENAME the name of the role to be created. The code will be placed in
  a subdirectory of the working directory with the same name as the role.
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
role_name="$1"
role_skeleton="${HOME}/CfgMgmt/roles/skeleton"

role_dir="${PWD}/${role_name}"
#}}}

# Script proper

# If the directory already exists, don't do anything!
if [ -d "${role_dir}" ]; then
  echo "A directory with name ‘${role_name}’ already exists, bailing out" >&2
  exit 1
fi

# Copy the role skeleton code
cp -r "${role_skeleton}" ./"${role_name}"

# Remove the Git repository
rm -rf "${role_dir}"/.git

# Remove Vim history files
find "${role_dir}" -type f -name '.*~' -exec rm -f {} \;

# Replace placeholder text ROLENAME with actual role name
find "${role_dir}" -type f -exec sed -i -e "s/ROLENAME/${role_name}/g" {} \;

# Create role directory in tests

mkdir -p "${role_dir}"/tests/roles
cd "${role_dir}/tests/"
ln -sfn "../.." "roles/${role_name}"

# Initialise Git repo and do first commit
cd "${role_dir}"
git init
git add .
git commit -m "First commit from role skeleton"


