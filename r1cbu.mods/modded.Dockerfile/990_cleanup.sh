#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

echo "I: cleanup"
  find /target/etc -name "*.old" -delete
  find /target/etc -name "*-" -delete
  rmdir /target/etc/* 2> /dev/null || :
  rm -rf \
    /target/linuxrc \
    /target/etc/rsyncd.conf \
    /target/etc/logrotate.d \
    /target/etc/nginx \
    /target/mnt/emmc_* \
    /target/mnt/update \
  # EO rm -rf
