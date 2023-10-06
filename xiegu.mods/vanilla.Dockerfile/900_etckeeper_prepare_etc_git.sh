#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

cd /target/etc

git init .
git config user.name root
git config user.email root@
: > .gitignore
echo resolv.conf >> .gitignore
echo *- >> .gitignore

git add .gitignore
git commit .gitignore -m "initial commit"

git add .
git commit -m "image: vanilla"
