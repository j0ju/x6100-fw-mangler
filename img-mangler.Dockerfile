# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

# set base, copy scripts & out-of-tree resources
FROM debian:bookworm-slim

COPY img-mangler/docker-build-helper.sh /src/img-mangler/
COPY img-mangler/Dockerfile/ /src/img-mangler/Dockerfile

COPY img-mangler/cleanup-rootfs.sh /lib/cleanup-rootfs.sh

COPY xiegu.mods/modded.Dockerfile/filesystem/etc/vim/vimrc.local /etc/vim/vimrc.local
COPY xiegu.mods/modded.Dockerfile/filesystem/etc/mc/mc.ini /etc/mc/mc.ini
COPY xiegu.mods/modded.Dockerfile/filesystem/root/.gitconfig /etc/gitconfig

# set environment - all build containers inherit this
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

# run scripts that do the modifications steps in one layer
# * moving files around - see # copy scripts & outoftree resources above
# * adding stuff, etc
RUN set -e ;\
    : set -x ;\
  exec /bin/sh \
    /src/img-mangler/docker-build-helper.sh \
    /src/img-mangler/Dockerfile
