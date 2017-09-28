#! /bin/bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Filter out card names and rarities from an MtG text spoiler file,
# e.g. as used by Magic Workstation.
# Text spoilers can be found at http://forums.mtgsalvation.com/
#

function usage()
{
echo << _EOF_
Usage: ${0} {-h,--help,FILE}
 where FILE is a text spoiler for a Magic the Gathering set.
_EOF_
}

if [[ "$#" -ne "1" ]]; then
    usage
    exit 1
fi

if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
    usage
    exit 0
fi

if [[ ! -f "${1}" ]]; then
    echo "File not found: ${1}"
    usage
    exit 1
fi

#----- Script proper -----

names=$(mktemp)
rarities=$(mktemp)

# Get card names, remove DOS EOLs
grep '^Card Name' "${1}" | sed 's/Card Name:\s*//' | sed 's/$//' > ${names} 
# Get rarities
grep '^Rarity' "${1}" | sed 's/Rarity:\s*//' > ${rarities}

# put it all together
paste ${names} ${rarities}

rm ${names} ${rarities}

