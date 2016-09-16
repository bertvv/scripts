#! /usr/bin/bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# PURPOSE
# See usage() for details.

#{{{ Bash settings
# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
set -o pipefail
#}}}
#{{{ Variables
readonly SCRIPT_NAME=$(basename "${0}")

IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

#}}}

main() {
  check_args "${@}"

  find_missing_citations
}

#{{{ Helper functions

# Check if command line arguments are valid
check_args() {
  [ "${#}" -eq "0" ]  && return

  case "${1}" in
    '-h'|'--help'|'-?')
      usage
      exit 0
      ;;
    *)
      echo "Invalid option(s)/argument(s)" 1>&2
      usage
      exit 1
      ;;
  esac
}

# Print usage message on stdout
usage() {
cat << _EOF_
Usage: ${SCRIPT_NAME} [OPTION]

  This script will search in the current directory which entries in the BibTeX
  files were never cited in the LaTeX document.

OPTIONS:

  -h, --help   Prints this help message

EXAMPLES:

$ ${SCRIPT_NAME}
-Geerling2016
-VanVreckem2015

The two BibTeX keys printed here are in the BibTeX database, but were never
cited in the text.

_EOF_
}

# Prints a list of BibTeX keys of sources that were cited in the text
cited_entries() {
  fgrep '@cite' ./*.aux \
    | sed 's/.*{//' \
    | sed 's/}$//' \
    | sort --unique
}

# Prints a list of BibTeX keys in the database(s)
available_entries() {
  fgrep '@' ./*.bib \
    | grep -v '@Comment' \
    | sed 's/.*{//' \
    | sed 's/,$//' \
    | sort --unique
}

find_missing_citations() {
  diff --unified=0 <(available_entries) <(cited_entries) \
    | tail --lines=+3 \
    | grep '^-'
}
#}}}

main "${@}"

