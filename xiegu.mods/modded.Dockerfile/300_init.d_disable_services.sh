#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

echo "I: disable services"
  mkdir /target/etc/rc.d/disabled
  cd /target/etc/rc.d
  mv \
    S70vsftpd S59snmpd S46ofono S48sntp S49ntp \
    disabled
