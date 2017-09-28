#! /usr/bin/env bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# "Unvagrantify" a VM and export to OVA.

set -u # abort on unbound variable

#{{{ Variables
#}}}

 #{{{ Functions

usage() {
cat << _EOF_
Usage: ${0} VM_NAME
  with VM_NAME the name of a VirtualBox VM.

Available boxes:
_EOF_

VBoxManage list vms
}

#}}}
# {{{ Command line parsing

if [[ "$#" -ne "1" ]]; then
    echo "Expected 1 argument, got $#" >&2
    usage
    exit 2
fi

vm="$1"

#}}}
# Script proper

if [[ -z "$(vboxmanage list vms | grep \"${vm}\")" ]]; then
  echo "This is not a VM: ${vm}. Choose one of the following:" >&2
  vboxmanage list vms >&2
  exit 1
fi

vboxmanage sharedfolder remove "${vm}" --name "vagrant"

vboxmanage export "${vm}" --output "${vm}.ova" --options manifest
