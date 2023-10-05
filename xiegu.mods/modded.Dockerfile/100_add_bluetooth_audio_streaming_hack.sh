#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
set -x

echo "I: install bluetooth stream hack"
  git clone https://github.com/busysteve/X6100-Bluetooth-Audio.git /target/tmp/bthack
  chroot /target sh -x -c "cd /tmp/bthack; . ./install.sh"
  rm -rf /tmp/bthack
