#! /usr/bin/bash
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
top_dir="${HOME}/Documents/Vakken/"
ac_year="15-16"

bookmark_dir="${HOME}/c/"
#}}}
# Script proper

# Cleanup current bookmark dir
if [[ -d "${bookmark_dir}" ]]; then
  rm --recursive --force "${bookmark_dir}"
fi
mkdir --parents "${bookmark_dir}"

# Create bookmarks
for course_year_dir in $(find "${top_dir}" -type d -name "${ac_year}"); do
  course_dir="${course_year_dir%/${ac_year}}"
  course_name="${course_dir#${top_dir}}"
  bookmark="${bookmark_dir}${course_name}"
  #echo "${course_year_dir} -> ${bookmark}"
  ln --symbolic --force --verbose "${course_year_dir}" "${bookmark}"
done


