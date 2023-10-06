#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

rm -f                         /target/sbin/syslogd
ln -s /opt/alpine/bin/busybox /target/sbin/syslogd

mkdir -p /target/etc/default
cat > /target/etc/default/syslogd << EOF
# /etc/default/syslogd

# Additional argument for syslogd
#SYSLOGD_ARGS=
# see /sbin/syslogd -h for more
EOF
