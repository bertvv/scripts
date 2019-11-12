#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# PURPOSE

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
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

readonly gitattr_url='https://gist.githubusercontent.com/bertvv/6c99b8feab64c473eb5e98dc676b4b4e/raw/e78e57957b4886f44abbbc7a92e68ca9eab723b6/.gitattributes'
#}}}

main() {
  wget "${gitattr_url}"
  git add .gitattributes
  git commit --message="Added .gitattributes for correct DOS/Linux line endings"
}

main "${@}"

