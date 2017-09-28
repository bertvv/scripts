#! /usr/bin/env bash
#
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Given directory structure like
#
# ~/Documents/Vakken
#    Enterprise Linux/   -> course name
#      12-13/            -> academic year
#      13-14/
#      14-15/
#    Project/
#      13-14/
#      14-15/
#
# Create symbolic links for directories of the form
#
#   ~/Vakken/${course}/${academic_year}/ into ~/c/${course}

set -e # abort on nonzero exitstatus
set -u # abort on unbound variable

#{{{ Variables
readonly top_dirs="${HOME}/Documents/Vakken/ ${HOME}/Documents/Avondschool/"
readonly ac_year="17-18"

readonly bookmark_dir="${HOME}/c/"
noop="false"
#}}}
#{{{ Functions

# Print usage message on stdout
usage() {
cat << _EOF_
Usage: ${0} [OPTION]

  Creates a symlink to all course directories for the current academic year to
  a bookmark directory.

OPTIONS:

  -h, -?, --help
      prints this help message
  -d, -n, --dry-run, --noop
      only shows the links that would be created
_EOF_
}

# Usage: die MESSAGE
#
# Prints a message to stderr and exits with a nonzero exit status
die() {
  printf "Error: %s ${*}\n" 1>&2
  usage
  exit 1
}

process_command_line_args() {
  [ "${#}" -eq "0" ] && return

  case "${1}" in
    "-h"|"-?"|"--help")
      usage
      exit 0
      ;;
    "-d"|"-n"|"--dry-run"|"--noop")
      noop="true"
      ;;
    *)
      die "Invalid option/argument."
      ;;
  esac
}



# Usage: cleanup_bookmark_dir
#
# Remove existing links in bookmark dir
cleanup_bookmark_dir() {
  if [[ -d "${bookmark_dir}" ]]; then
    rm --recursive --force "${bookmark_dir}"
  fi
  mkdir --parents "${bookmark_dir}"
}

# Usage: course_dirs_in DIR
#
# searches for directories matching ${ac_year} in the specified directory.
course_dirs_in() {
  local top_dir="${1}"
  find "${top_dir}" -type d -name "${ac_year}"
}

# Usage: create_links_for DIR
#
# Creates links in ${bookmarks_dir} for all course directories found in the
# specified top directory
create_links_for() {
  local top_dir="${1}"
  local course_year_dirs
  course_year_dirs=$(course_dirs_in "${top_dir}")

  for course_year_dir in ${course_year_dirs}; do
    # strip ${ac_year} from end of path
    course_dir="${course_year_dir%/${ac_year}}"

    # strip top directory from start of path, leaving only the course name
    course_name="${course_dir#${top_dir}}"
    bookmark="${bookmark_dir}${course_name}"

    if [ "${noop}" = "true" ]; then
      echo "${course_year_dir} -> ${bookmark}"
    else
      ln --symbolic --force --verbose "${course_year_dir}" "${bookmark}"
    fi
  done
}
#}}}

# Script proper
process_command_line_args "${@}"

cleanup_bookmark_dir

for top_dir in ${top_dirs}; do
  create_links_for "${top_dir}"
done
