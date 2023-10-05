#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

. ${0%/*}/config


# install required packages
  apk add --no-cache $REQ_PKGS

# pre-seed git config
  git config --global init.defaultBranch main
  ( cd /etc
    git init .
  )

# install packages for tarballs
  apk add --no-cache $PKGS

