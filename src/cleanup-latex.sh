#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Clean up LaTeX help files

if [ $# -ge '1' ] && [ -d "${1}" ]; then
  dir="${1}"
else
  dir="${PWD}"
fi

rm -vf "${dir}"/*.{bak,aux,log,nav,out,snm,ptc,toc,bbl,blg,idx,ilg,ind,tcp,vrb,tps,lof,log,lol,lot,synctex.gz,fls,fdb_latexmk,bcf,run.xml,xdv} 2> /dev/null
rm -vrf "${dir}"/_minted* 2> /dev/null # directory for Pygments syntax coloring

