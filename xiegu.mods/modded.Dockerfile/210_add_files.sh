#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

echo "I: add fs modifications"
  cd /src/xiegu.mods/modded.Dockerfile/filesystem
  find . ! -type d | while read f; do
    rm -f "/target/$f"
      mkdir -p "/target/${f%/*}"
      mv "$f" "/target/$f"
    done
  chroot /target /usr/local/sbin/update-rc
