# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
FROM debian:bookworm-slim

ENV \
  DEBIAN_FRONTEND=noninteractive \
  DEBIAN_CHROOT=docker \
  LANG=C.UTF-8 \
  LANGUAGE=C.UTF-8 \
  LC_CTYPE=C.UTF-8 \
  LC_NUMERIC=C.UTF-8 \
  LC_TIME=C.UTF-8 \
  LC_COLLATE=C.UTF-8 \
  LC_MONETARY=C.UTF-8 \
  LC_MESSAGES=C \
  LC_PAPER=C.UTF-8 \
  LC_NAME=C.UTF-8 \
  LC_ADDRESS=C.UTF-8 \
  LC_TELEPHONE=C.UTF-8 \
  LC_MEASUREMENT=C.UTF-8 \
  LC_IDENTIFICATION=C.UTF-8

COPY img-mangler/cleanup-rootfs.sh /lib/cleanup-rootfs.sh
COPY xiegu.mods/filesystem/etc/vim/vimrc.local /etc/vim/vimrc.local
COPY xiegu.mods/filesystem/etc/mc/mc.ini /etc/mc/mc.ini
COPY xiegu.mods/filesystem/root/.gitconfig /etc/gitconfig

RUN set -e; \
    mkdir -p /target ; \
    cp /etc/gitconfig /root/.gitconfig ;\
    echo 'APT::Get::Update::SourceListWarnings::NonFreeFirmware "false";' > /etc/apt/apt.conf.d/no-bookworm-firmware.conf ;\
    sed -i -e '/Components/ s/main/main non-free contrib/' /etc/apt/sources.list.d/debian.sources; \
    apt-get update; \
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
      ; \
    echo 'case $- in *i*) . /etc/bash_completion ;; esac' >> /etc/bash.bashrc ;\
    sh /lib/cleanup-rootfs.sh
