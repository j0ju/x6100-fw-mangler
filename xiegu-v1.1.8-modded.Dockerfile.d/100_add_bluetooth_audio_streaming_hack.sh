#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

echo "I: install bluetooth stream hack"
  git clone https://github.com/busysteve/X6100-Bluetooth-Audio.git /target/tmp/bthack
  chroot /target sh -c "
    #set -x
    cd /tmp/bthack
    . ./install.sh
  " # EO chroot
  rm -rf /tmp/bthack

chroot /target \
  etckeeper commit -m "install bluetooth stream hack: https://github.com/busysteve/X6100-Bluetooth-Audio.git"
