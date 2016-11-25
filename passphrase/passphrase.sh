#!/bin/bash
#
# Generates random passphrases, as suggested by http://xkcd.com/936/

#
# Variables
#

# Length of the passphrase
num_words=5

# Boundaries of word length
min_word_length=4
max_word_length=8

# Text files containing one word per line
sources="en-google-10000.txt nl-opensubtitles-10000.txt"

# Temporary file containing selected words
wordlist=$(mktemp)

#
# Select suitable words from the specified sources
#
for src in ${sources}; do
  # First, select only words of the specified length, then filter out words
  # containing letters that can cause azerty/qwerty confusion
  grep "^[[:alnum:]]\{${min_word_length},${max_word_length}\}$" "${src}" \
    | grep --ignore-case --invert-match "[amqwz]" \
    >> "${wordlist}"
done

#
# Generate passphrases of the specified length from the selected words
#

answer='y'
until [ "${answer}" = 'n' ]; do
  shuf --head-count="${num_words}" "${wordlist}" \
    | xargs echo -n
  echo
  read -p "More? [Y/n] " answer
done

rm "${wordlist}"
