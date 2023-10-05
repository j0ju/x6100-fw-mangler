#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

. ${0%/*}/config

# create tarballs from binaries
  for BIN in $BINPKGS; do
    sh -e /src/img-mangler/alpine-mk-bin-tarball.sh $BIN $OUTPUT_DIR
  done
