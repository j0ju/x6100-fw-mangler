#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

echo "I: set root shell to /bin/bash"
  sed -i -e '/^root/ s|/bin/sh|/bin/bash|' /target/etc/passwd

chroot /target \
  etckeeper commit -m "root: change shell to /bin/bash"
