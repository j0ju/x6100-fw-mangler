#!/bin/sh
set -e

usage() {
  echo "usage: $0 <template> <container name>" 1>&2
  if [ -n "$*" ]; then
    echo "$*" 1>&2
  fi
  exit 1
}

setx() {
  #echo "+$*"
  "$@"
}
apt-get clean

for d in /usr/share/man/*; do
  [ -d "$d" ] || continue
  l="${d##*/}"
  case "$l" in
    man[0-9] )
      which man > /dev/null 2>&1 && continue || :
      ;;
  esac
  setx rm -rf "$d"
done

rm -f 2> /dev/null \
  /var/cache/apt/archives/* \
  /var/cache/apt/archives/partial/* \
  /var/lib/apt/lists/* \
  /var/lib/apt/lists/partial/* \
  /var/lib/dpkg/info/*.preinst \
  /var/lib/dpkg/info/*.postinst \
  /var/log/* /var/log/*/* \
  || :
rm -rf 2> /dev/null \
  /usr/share/doc/* \
  /usr/share/info/* \
  /usr/share/man/?? /usr/share/man/??.* /usr/share/man/??_?? \
  || : #
