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

RUN set -e; \
    mkdir -p /target; \
    sed -i -e '/Components/ s/main/main non-free contrib/' /etc/apt/sources.list.d/debian.sources; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      debootstrap e2fsprogs btrfs-progs f2fs-tools gdisk unzip kpartx mc zstd file pixz xzip cpio pigz git dosfstools \
      vim-nox bash-completion initramfs-tools build-essential unrar unzip \
      ; \
    apt-get clean; \
    sh /lib/cleanup-rootfs.sh

