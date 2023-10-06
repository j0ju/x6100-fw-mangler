#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

echo "I: add fs modifications"
  cd /src/xiegu-v1.1.7-modded.Dockerfile.d/filesystem
  find . ! -type d | while read f; do
    rm -f "/target/$f"
      mkdir -p "/target/${f%/*}"
      mv "$f" "/target/$f"
    done

chroot /target \
  etckeeper commit -m "add filesystem mods"
