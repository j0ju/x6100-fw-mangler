#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

echo "I: disable usb mmc automounting"
  echo "mediafs /media tmpfs mode=0755,nosuid,nodev 0 0" >> /target/etc/fstab
  mkdir -p /target/etc/udev/rules.d/disabled
  mv -f /target/etc/udev/rules.d/*-auto-mount.rules /target/etc/udev/rules.d/disabled

chroot /target \
  etckeeper commit -m "udev: disable USB/MMC automounting"
