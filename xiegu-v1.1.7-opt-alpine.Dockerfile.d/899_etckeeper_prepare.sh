#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

# fix hardlinks in /etc, git complains
rm -f /target/etc/terminfo/v/vt220
cp /target/etc/terminfo/v/vt200 /target/etc/terminfo/v/vt220
