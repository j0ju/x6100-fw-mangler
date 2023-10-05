#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

. ${0%/*}/config

# create tarballs from packages
  for BIN in $PKGS; do
    sh -e /src/img-mangler/alpine-mk-pkg-tarball.sh $BIN $OUTPUT_DIR
  done
