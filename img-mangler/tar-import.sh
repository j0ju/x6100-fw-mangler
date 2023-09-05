#!/bin/sh
set -e
set -x

IN="$1"
IMGNAME="$2"

CONTAINER="$(docker run --rm -d x6100:img-mangler sleep 3600)"
trap "docker rm -f $CONTAINER" EXIT HUP INT QUIT PIPE KILL TERM

DECOMPRESSOR=cat

docker exec "$CONTAINER" mkdir -p /target
case "$IN" in
  *.zst | *.zstd ) DECOMPRESSOR="zstd -cd" ;;
  *.gz | *.tgz ) DECOMPRESSOR="gzip -cd" ;;
  *.xz | *.txz ) DECOMPRESSOR="xz -cd" ;;
esac

$DECOMPRESSOR < "$IN" | \
  docker exec -i "$CONTAINER" tar xf - --xattrs --selinux --acls --atime-preserve --numeric-owner -C /target

docker commit -c "CMD rm -f /target/etc/resolv.conf; cp /etc/resolv.conf /target/etc/resolv.conf; chroot /target su -"  "$CONTAINER" "$IMGNAME"
