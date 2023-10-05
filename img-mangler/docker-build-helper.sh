#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

#PS4='> ${0##*/}[$$]: '
PS4='> ${0##*/}: '
#set -x

if [ ! -d "$1" ]; then
  echo "E: $1 is not a directory, ABORT" >&2
  exit 1
fi

set -x
exec run-parts \
  --exit-on-error -v --umask 022 --regex "[-_.0-9a-z]+" -- "$1"
