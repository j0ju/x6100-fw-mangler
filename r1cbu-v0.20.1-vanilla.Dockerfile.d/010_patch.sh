#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
set -x

tar xf /tmp/R1CBU-v0.20.1.patch.tar.gz -C /target
rm /tmp/R1CBU-v0.20.1.patch.tar.gz
