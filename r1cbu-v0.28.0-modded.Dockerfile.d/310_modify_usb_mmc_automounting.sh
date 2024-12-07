#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

echo "I: /etc/fstab: add tmpfs at /media"
  echo "mediafs /media tmpfs mode=0755,nosuid,nodev 0 0" >> /target/etc/fstab

echo "I: /etc/fstab: remove /mnt"
  sed -i -e '/[/]mnt/ d' /target/etc/fstab
