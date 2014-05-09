#!/bin/bash
#
# Created:  Mon 11 Jun 2012 02:19:45 PM CEST
# Modified: Thu 01 May 2014 02:59:16 pm CEST CEST CEST CEST CEST CEST
# Author:   Bert Van Vreckem <bert.vanvreckem@gmail.com>
#
# generate a random passphrase, as suggested by http://xkcd.com/936/
num=5
sources=/usr/share/dict/words #/usr/share/dict/dutch
#sources=/usr/share/hunspell/nl_BE.dic
wordlist=$(mktemp) || exit 2

for src in ${sources}; do
    # take words from 2-10 chars and  avoid azerty/qwerty-confusion
    grep '^[[:alnum:]]\{2,10\}$' ${src} \
      > ${wordlist}
#      | grep -iv "[amqwz]" \
done

while true; do
  shuf -n $num $wordlist | xargs echo -n
  echo
  read -s -p "[Enter] for more, [CtrlC] to exit."
  echo -en "\r"
done

rm ${wordlist}
