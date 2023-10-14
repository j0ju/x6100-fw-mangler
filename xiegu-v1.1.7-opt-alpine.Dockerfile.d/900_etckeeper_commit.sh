#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
set -x

# convert git to etckeeper backed repo
chroot /target etckeeper init
chroot /target etckeeper commit -m "image: opt-alpine"

