#! /usr/bin/bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Set up scaffolding for an Ansible role based on
# https://github.com/bertvv/ansible-role-skeleton/
#
# This script works with v2.0.0 of ansible-role-skeleton.
#
# *Warning!* This script requires Git v2.5.0 or newer

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

# Replace placeholder ROLENAME with the actual role name in the
# specified directory
subst_role_name() {
  local dir="${1}"

  find "${dir}" -type f -exec sed --in-place \
    --expression "s/ROLENAME/${role_name}/g" {} \;
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
role_skeleton="https://github.com/bertvv/ansible-role-skeleton"

download_dir="/tmp/role-skeleton"
role_dir="${PWD}/${role_name}"

# Your github username (only used in instructions for pushing to Github
# at the end of the script).
github_username=bertvv
#}}}

# Script proper

# If the directory already exists, don't do anything!
if [ -d "${role_dir}" ]; then
  echo "A directory with name ‘${role_name}’ already exists, bailing out" >&2
  exit 1
fi

# Download the role from Github
git clone --quiet "${role_skeleton}" "${download_dir}"

# Create a directory for the new role
mkdir "${role_name}"

# Copy the role skeleton code
rsync --archive --exclude '.git' "${download_dir}/" "${role_dir}"

# Replace placeholder text ROLENAME with actual role name
subst_role_name "${role_dir}"

# Put the current year into the LICENSE file
sed --in-place --expression "s/YEAR/$(date +%Y)/" "${role_dir}/LICENSE.md"

# Initialise Git repo and do first commit
cd "${role_dir}"
git init --quiet
git add .
git commit --quiet --message "First commit from role skeleton"

# Create empty branch for test code
git checkout --quiet --orphan tests
git rm -r --force --quiet .

# Copy test code from original skeleton
cd "${download_dir}"
git fetch --quiet origin tests
git checkout --quiet tests
rsync --archive --exclude '.git' "${download_dir}/" "${role_dir}"
subst_role_name "${role_dir}"

# Set up the branch
cd "${role_dir}"
git add .
git commit --quiet --message "Set up test branch"

# In the master branch, create a worktree for the test code
git checkout --quiet master
git worktree add tests tests 2> /dev/null

# Create subdirectory for roles used in the test playbook
cd "${role_dir}/tests/"
mkdir roles

# Link from roles to the root directory of the project
ln --symbolic --force --no-dereference "../.." "roles/${role_name}"
git add .
git commit --quiet --message "Make role available in test environment"

# Delete the download
rm --recursive --force "${download_dir}"


# Finish with an informative message of what to do next
cat << _EOF_
Role ‘${role_name}’ was created!

Directory ${role_name}/tests/ is a git-worktree pointing to the branch ‘tests’.

Instructions for pushing to Github:
1. Create a new repository, say ansible-role-${role_name}
2. git remote add origin git@github.com:${github_username}/ansible-role-${role_name}.git
3. git push -u origin master
4. cd tests
5. git push -u origin tests
_EOF_
