#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

apt-get update 
apt-get install -y --no-install-recommends \
  debootstrap \
  fdisk gdisk kpartx \
  dosfstools e2fsprogs btrfs-progs f2fs-tools \
  libubootenv-tool u-boot-tools \
  unzip unrar zstd file pixz xzip cpio pigz \
  python3-pip virtualenv \
  qemu-user-static \
  mc vim-nox bash-completion \
  procps psmisc man-db \
  git \
  build-essential libncurses-dev \
  rsync bc cmake bzip2 \
  bspatch bsdiff hexer bbe \

