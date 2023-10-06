#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

rm -f /target/usr/app_qt/xparam.db
ln -s ../../etc/xgradio/xparam.db /target/usr/app_qt/xparam.db
