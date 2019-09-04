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
readonly main_font="DejaVu Sans"
readonly mono_font="DejaVu Sans Mono"
readonly font_size="12pt"
readonly margins="top=2cm, bottom=3cm, left=1.5cm, right=1.5cm"
readonly paper_size="a4paper"
readonly other_options='' #"--number-sections" # --table-of-contents 
readonly latex_engine="lualatex"
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

  pandoc \
    --variable mainfont="${main_font}" \
    --variable monofont="${mono_font}" \
    --variable fontsize="${font_size}" \
    --variable geometry:"${margins}" \
    --variable geometry:"${paper_size}" \
    ${other_options} \
    -f markdown "${file}" \
    --pdf-engine="${latex_engine}" \
    -o "${output}"
}

# Check if command line arguments are valid
check_args() {
  if [ "${#}" -eq "0" ]; then
    echo "Expected at least 1 argument, got ${#}" >&2
    usage
    exit 2
  fi
}

# Print usage message on stdout
usage() {
cat << _EOF_
Usage: ${0} [FILE]...

  Converts the specified Markdown documents to PDF using pandoc.

EXAMPLES:
_EOF_
}

#}}}

main "${@}"

