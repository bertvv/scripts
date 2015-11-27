#! /usr/bin/bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Clean up LaTeX help files

rm -v ./*.aux ./*.log ./*.nav ./*.out ./*.snm ./*.toc \
  ./*.bbl ./*.blg ./*.idx ./*.ilg ./*.ind ./*.tcp ./*.vrb \
  ./*.tps ./*.lof ./*.lot 2> /dev/null

