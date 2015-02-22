#! /usr/bin/bash
#
# Author: Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# Initialise shell, dotfiles

set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

#{{{ Functions

ensure_dir() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
  fi
}

usage() {
cat << _EOF_
Usage: ${0} 

_EOF_
}

#}}}
#{{{ Variables
opt="${HOME}/opt"
promptastic=${opt}/promptastic/promptastic.py

font_dir="${HOME}/.fonts/"
fontconf_dir="${HOME}/.config/fontconfig/conf.d"
#}}}

# Script proper

ensure_dir "${opt}"

# First, install promptastic
# Source: https://github.com/bertvv/dotfiles/blob/master/.bash.d/prompt.sh
if [ ! -f "${promptastic}" ]; then
  cd "${opt}"
  git clone https://github.com/nimiq/promptastic.git
fi

if [ ! -f "${font_dir}/PowerlineSymbols.otf" ]; then
  ensure_dir "${font_dir}"
  cd "${font_dir}"
  wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf
  fc-cache -vf ~/.fonts
fi

if [ ! -f "${fontconf_dir}/10-powerline-symbols.conf" ]; then
  ensure_dir "${fontconf_dir}"
  cd "${fontconf_dir}"
  wget https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
fi

# Initialise dotfiles
# Source: https://stackoverflow.com/questions/2411031/how-do-i-clone-into-a-non-empty-directory
cd "${HOME}"

git init
git remote add origin git@github.com:bertvv/dotfiles.git
git fetch
git checkout -t origin/master
git submodule update --init --recursive

