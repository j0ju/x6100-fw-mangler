#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

echo "I: extract update tarball to /"
  mv /target /target.old
  mkdir /target
  tar xf /target.old/part3/rootfs.tar -C /target
  rm -rf /target.old
