#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

for p in /tarballs/*.tar.gz; do
  [ -r "$p" ] || \
    continue
  echo "I: extract $p"
  tar xzf "$p" -C /target
done
