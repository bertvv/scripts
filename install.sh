#!/bin/bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Install selected scripts in the user's ~/bin directory by creating symbolic
# links to the actual scripts. The links will have their extension removed.
#
# Thes scripts should be stored in a subdirectory src/. If you want a script to
# be installed, just make it executable, otherwise it will be skipped.
#

#{{{ Bash settings
# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail
#}}}
#{{{ Variables
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

# installation destination directory
readonly dst_dir=${HOME}/.local/bin

# directory where this script is located (should contain
# subdirectory src/ containing the actual scripts
readonly script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# script directory
readonly src_dir=${script_dir}/src

# scripts to be installed. If you want a script to be installed, make it
# executable
to_install=$(find "${src_dir}" -type f \( -executable -and ! -iname ".*" \) -printf '%f\n' | sort)
#}}}

if [ ! -d "${dst_dir}" ]; then
  mkdir -p "${dst_dir}"
fi

for s in ${to_install}; do
  # determine path to source and destination files
  source_file="${src_dir}/${s}"
  destination_file="${dst_dir}/${s%.*}"  # remove extension from link

  if [[ ! -f "${source_file}" ]]; then

    # Source script not found
    echo "Skipping nonexistent ${source_file}" >&2

  else

    # If the destination directory already contains a script
    # that is not a link, it should not be overwritten
    if [[ -f "${destination_file}" && ! -h "${destination_file}" ]]; then
      echo "Skipping ${destination_file}: already exists, is a regular file" >&2
    else
      # create the link
      ln -vsf "${source_file}" "${destination_file}"
    fi

  fi
done
