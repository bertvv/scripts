#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Converts a Markdown document to a PDF using pandoc.
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
readonly script_name=$(basename "${0}")
readonly script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

# Conversion settings
readonly other_options='' #"--number-sections" # --table-of-contents 
readonly latex_engine="xelatex"
#}}}

main() {
  check_args "${@}"

  convert_markdown_files_to_pdf "${@}"
}

#{{{ Helper functions


# Usage: convert_markdown_files FILE...
convert_markdown_files_to_pdf() {
  for file in "${@}"; do
    convert_markdown_file_to_pdf "${file}"
  done
}

convert_markdown_file_to_pdf() {
  local file="${1}"
  local output="${file%.*}.pdf"

  set -x
  pandoc \
    ${other_options} \
    -f markdown "${file}" \
    --pdf-engine="${latex_engine}" \
    -o "${output}"
  set +x
}

# Check if command line arguments are valid
check_args() {
  if [ "${#}" -eq "0" ]; then
    echo "Expected at least 1 argument, got ${#}" >&2
    usage
    exit 2
  fi

  if [ "${1}" = '-h' ] || [ "${1}" = '--help' ]; then
    usage
    exit 0
  fi

  if [ "${1}" = '-t' ] || [ "${1}" = '--template' ]; then
    print_template
    exit 0
  fi

}

# Print usage message on stdout
usage() {
cat << _EOF_
Usage: ${0} FILE...
       ${0} -h|--help
       ${0} -t|--template

Converts the specified Markdown documents to PDF using pandoc.

OPTIONS

-h, --help

  Prints this help message

-t, --template

  Prints a template for a Markdown document with a YAML heading specifying
  the layout (fonts, margin, title, etc)
_EOF_
}

print_template() {
cat << _EOF_
---
title: 'Titel'
subtitle: 'Subtitel'
author: 'Auteur'
date: 'Datum'
lang: nl-BE
documentclass: article
mainfont: Montserrat
monofont: Fira Code
fontsize: 11pt
papersize: a4paper
geometry: margin=2cm
abstract: |
  Samenvatting
...

# Sectie1


_EOF_
}

#}}}

main "${@}"

