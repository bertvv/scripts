#! /usr/bin/bash

bash ../../src/backup.sh

if [ "$1" = "clean" ]; then
  rm -rf destination
  mkdir destination
fi
