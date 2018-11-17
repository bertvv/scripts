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
readonly SCRIPT_NAME=$(basename "${0}")
readonly SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
#IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

# Conversion settings
readonly MAIN_FONT="DejaVu Sans"
readonly MONO_FONT="DejaVu Sans Mono"
readonly FONT_SIZE="11pt"
readonly MARGINS="top=2cm, bottom=3cm, left=1.5cm, right=1.5cm"
readonly PAPER_SIZE="a4paper"
readonly OTHER_OPTIONS="--table-of-contents --number-sections"
readonly LATEX_ENGINE="lualatex"
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
    --variable mainfont="${MAIN_FONT}" \
    --variable monofont="${MONO_FONT}" \
    --variable fontsize="${FONT_SIZE}" \
    --variable geometry:"${MARGINS}" \
    --variable geometry:"${PAPER_SIZE}" \
    ${OTHER_OPTIONS} \
    -f markdown "${file}" \
    --pdf-engine="${LATEX_ENGINE}" \
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

