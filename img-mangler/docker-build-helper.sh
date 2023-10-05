#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

#PS4='> ${0##*/}[$$]: '
PS4='> ${0##*/}: '
set -x

if [ -d "$1" ]; then
    exec run-parts \
      --exit-on-error -v --umask 022 --regex "[-_.0-9a-z]+" -- "$1" 
fi
