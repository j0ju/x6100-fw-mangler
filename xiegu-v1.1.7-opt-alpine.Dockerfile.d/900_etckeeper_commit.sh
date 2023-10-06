#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

cd /target/etc

# fix hardlinks in /etc, git complains
rm -f /target/etc/terminfo/v/vt220
cp /target/etc/terminfo/v/vt200 /target/etc/terminfo/v/vt220

# convert git to etckeeper backed repo
chroot /target etckeeper init
chroot /target etckeeper commit -m "image: opt-alpine"
