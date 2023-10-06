#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

. ${0%/*}/config

# install required packages
  apk add --no-cache $REQ_PKGS

# pre-seed git config
  git config --global init.defaultBranch main
  git config --global user.name root
  git config --global user.email root@
  ( cd /etc
    git init .
    echo "*"    >  .gitignore
    echo "**/*" >>  .gitignore
    git add -f .gitignore
    git commit -m "init" -q
  )

# install packages for tarballs
  apk add --no-cache $PKGS
