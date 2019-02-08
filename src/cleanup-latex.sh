#! /usr/bin/env bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Clean up LaTeX help files

rm -v ./*.{bak,aux,log,nav,out,snm,ptc,toc,bbl,blg,idx,ilg,ind,tcp,vrb,tps,lof,log,lot,synctex.gz,fls,fdb_latexmk,bcf,run.xml} 2> /dev/null
rm -vr _minted* 2> /dev/null # directory for Pygments syntax coloring

