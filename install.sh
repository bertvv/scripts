#!/bin/bash
#
# Created:  Fri 01 Mar 2013 10:31:23 AM CET
# Modified: Fri 09 May 2014 11:42:08 am CEST
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Install selected scripts in the user's bin directory
#

# base names (no extension) of the scripts to be installed
TO_INSTALL="backup screencast add-vim-bundle"

# installation destination directory
DST_DIR=~/bin

# directory where this script is located (should contain
# subdirectory src/ containing the actual scripts
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# script directory
SRC_DIR=${SCRIPT_DIR}/src


for s in $(echo ${TO_INSTALL}); do
  echo $s
  # determine path to source and destination files
  SRC=${SRC_DIR}/${s}.sh
  DST=${DST_DIR}/${s}

  if [[ ! -f "${SRC}" ]]; then

    # Source script not found
    echo "Skipping nonexistent ${SRC}" >&2

  else

    # make sure the script is executable
    chmod 750 "${SRC}"

    # If the destination directory already contains a script
    # that is not a link, it should not be overwritten
    if [[ -f "${DST}" && ! -h "${DST}" ]]; then
      echo "Skipping ${DST}: already exists, is a regular file" >&2
    fi
    
    # create the link
    ln -sf ${SRC} ${DST}

  fi
done
