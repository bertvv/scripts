#! /bin/bash
#
# Remove all files and directories in the user's home directory that are related to
# Cisco PacketTracer to circumvent the limitation of saving a file max. 3 times.
#
# Usage:
#
# refresh-packettracer
#
#        remove files *after confirmation*
#
# refresh-packettracer -f
#
#        remove files without asking for confirmation

set -o errexit
set -o nounset

# Function that will remove all PacketTracer files
delete_pt_files() {
  printf "Deleting all PacketTracer files\n"
  rm -rfv "${HOME}/.packettracer" \
    "${HOME}/.local/share/PacketTracer7" \
    "${HOME}/pt"  2> /dev/null
}

# Check for command line option -f (force, don't ask for confirmation)
if [ "${#}" -ge '1' ] && [ "${1}" = '-f' ]; then
  delete_pt_files
  exit 0
fi

# Print confirmation message (in red)
cat << _EOF_
[31mWarning!! this will remove all PacketTracer files on standard locations, including saves.
Move your .pkt files out of ${HOME}/pt/ if you want to keep them.[0m
Are you sure? [yN]
_EOF_

# Wait for user input
read -r input

# Delete files only if user confirmed
if [ "${input}" = 'y' ] || [ "${input}" = 'Y' ]; then
  delete_pt_files
fi
