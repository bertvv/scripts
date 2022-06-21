#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Lists the number of lines of code each collaborater contributed to a Git
# repository. See usage() for details.
#
# Source:
#   http://www.commandlinefu.com/commands/view/3889/prints-per-line-contribution-per-author-for-a-git-repository

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
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

# Debug info ('on' to enable)
readonly debug='on'

final_sort=cat
#}}}

main() {
  check_args "${@}"

  log "Number of commits"

  git log --pretty='format:%an' \
    | sort --ignore-case \
    | uniq --ignore-case --count \
    | eval ${final_sort}

  log "Number of lines"

  git ls-files \
    | xargs --max-args=1 --delimiter='\n' git blame --line-porcelain \
    | sed --silent 's/^author //p' \
    | sort --ignore-case \
    | uniq --ignore-case --count \
    | eval ${final_sort}
}

#{{{ Helper functions

# Check if command line arguments are valid
check_args() {
  if [ "${#}" -ne "0" ]; then
    if [ "${1}" = "-h" ] || [ "${1}" = "--help" ] || [ "${1}" = "-?" ]; then
      usage
      exit 0
    elif [ "${1}" = "-n" ] || [ "${1}" = "--numeric" ]; then
      final_sort="sort --numeric-sort --reverse"
    fi
  fi
}

# Print usage message on stdout
usage() {
cat << _EOF_
Usage: ${SCRIPT_NAME} [OPTIONS]

  Prints a list of all authors that contributed to the current Git repository
  and the total number of lines of code they contributed.

OPTIONS:

  -h, --help
          print this help message and exit.

  -n, --numeric
          sort authors by descending number of lines contributed.

REMARKS:

  The lines counted are based on the output of Git blame, that for each line
  gives the author that last modified that line. It is possible that this final
  change was minimal, while most of the line was actually contributed by
  another author. Also, binary files aren't handled well, which may influence
  the results.
_EOF_
}

# Usage: log [ARG]...
#
# Prints all arguments on the standard output stream
log() {
  printf '\e[0;33m>>> %s\e[0m\n' "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard output stream,
# if debug output is enabled
debug() {
  [ "${debug}" != 'on' ] || printf '\e[0;36m### %s\e[0m\n' "${*}"
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf '\e[0;31m!!! %s\e[0m\n' "${*}" 1>&2
}


#}}}

main "${@}"

