#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# PURPOSE
# Generates random passphrases, as suggested by https://xkcd.com/936/
# See usage() for details

#{{{ Bash settings
# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't hide errors within pipes
#set -o pipefail
#}}}
#{{{ Variables
readonly script_name=$(basename "${0}")
readonly script_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
IFS=$'\t\n'   # Split on newlines and tabs (but not on spaces)

# Color definitions
readonly reset='\e[0m'
readonly black='\e[0;30m'
readonly red='\e[0;31m'
readonly green='\e[0;32m'
readonly yellow='\e[0;33m'
readonly blue='\e[0;34m'
readonly purple='\e[0;35m'
readonly cyan='\e[0;36m'
readonly white='\e[0;37m'

# When set to 'y', will print out debug information
# Enable by calling the script with "DEBUG=y fancylongpw"
readonly debug_mode=${DEBUG:-n}

# Directory containing locale specific dictionaries (Hunspell)
readonly dict_path=/usr/share/myspell
# Temp file containing all selected words
readonly word_list=$(mktemp)

# Defaults
num_words=4
num_phrases=1
locales=('en_GB')

#}}}

main() {
  process_args "${@}"

  select_words

  generate_phrases

}

#{{{ Helper functions

select_words() {
  debug "Building word list:"
  for locale in "${locales[@]}"; do
    debug "  - ${locale}"
    cat "${dict_path}/${locale}.dic" >> "${word_list}"
  done
}

generate_phrases() {
  for ((i=0; i < num_phrases; i++)); do
    generate_phrase
  done
}

generate_phrase() {
  shuf "${word_list}" \
    | head --lines="${num_words}" \
    | sed 's/\/.*//' \
    | tr -d "'" \
    | xargs echo
}

process_args() {
  local optspec=':h:l:n:p:w:-:'

  while getopts "${optspec}" optchar; do
    case "${optchar}" in
      -)
        case "${OPTARG}" in
          help)
            usage
            cleanup
            exit 0
            ;;
          num-phrases)
            opt_arg="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
            num_phrases="${opt_arg}"
            debug "Parsed option --num-phrases ${num_phrases}"
            ;;
          num-phrases=*)
            opt_arg="${OPTARG#*=}"
            num_phrases="${opt_arg}"
            debug "Parsed option --num-phrases=${num_phrases}"
            ;;
          num-words)
            opt_arg="${!OPTIND}"; OPTIND=$(( OPTIND + 1 ))
            num_words="${opt_arg}"
            debug "Parsed option --num-words ${num_words}"
            ;;
          num-words=*)
            opt_arg="${OPTARG#*=}"
            num_words="${opt_arg}"
            debug "Parsed option --num-words=${num_words}"
            ;;
          *)
            if [ "${OPTERR}" = '1' ] || [ "${optspec:0:1}" = ':' ]; then
              error "Unknown option: --${OPTARG}"
              usage
              cleanup
              exit 1
            fi
            ;;
        esac
        ;;
      h)
        usage
        cleanup
        exit 0
        ;;
      p)
        num_phrases="${OPTARG}"
        debug "Parsed option -n ${num_phrases}"
        ;;
      w)
        num_words="${OPTARG}"
        debug "Parsed option -w ${num_words}"
        ;;
      *)
        if [ "${OPTERR}" = '1' ] || [ "${optspec:0:1}" = ':' ]; then
          error "Unknown option: -${OPTARG}"
          usage
          cleanup
          exit 1
        fi
        ;;
    esac
  done
}

function cleanup() {
  debug "Cleaning up ${word_list}"
  rm "${word_list}"
}

# Print usage message on stdout
usage() {
cat << _EOF_
Usage: ${script_name} [OPTIONS]... [ARGS]...

  Generates random passphrases, as suggested by https://xkcd.com/936/

OPTIONS:

  -p, --num-phrases=NUMBER   (default: ${num_phrases})

         The number of phrases to be generated. By default, the user is
         prompted after every phrase to generate a new one or abort.

  -w, --num-words=NUMBER    (default: ${num_words})

         The number of words the passphrase should consist of

  -l, --locale=LOCALE[,LOCALE]... (default: ${locales[@]})

         Specifies the language(s)/locale(s) to select words from. This can be
         a comma separated list with no spaces. Locales are specified with ISO
         language and country code, separated by underscore, e.g. nl_BE, en_GB.

  -h, --help

         Shows this message and exits

EXAMPLES:

  $ ${script_name}
  $ ${script_name} --num-words=5 --num-phrases=10
  $ ${script_name} --locale=nl_BE,en_GB
_EOF_
}

# Usage: info [ARG]...
#
# Prints all arguments on the standard output stream
info() {
  printf "${yellow}### %s${reset}\n" "${*}"
}

# Usage: debug [ARG]...
#
# Prints all arguments on the standard output stream
debug() {
  if [ "${debug_mode}" = 'y' ]; then
    printf "${cyan}### %s${reset}\n" "${*}"
  fi
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
  printf "${red}!!! %s${reset}\n" "${*}" 1>&2
}
#}}}

if [ "${debug_mode}" = 'y' ]; then
  set -x
fi

main "${@}"

if [ "${debug_mode}" = 'y' ]; then
  set +x
fi

trap cleanup HUP INT TERM EXIT
