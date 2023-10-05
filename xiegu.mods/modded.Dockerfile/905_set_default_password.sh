#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

echo "I: set new default password"
  ( echo "x6100"; echo "x6100"; echo ) | chroot /target passwd root
