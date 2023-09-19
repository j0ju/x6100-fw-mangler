#!/bin/sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
set -e

IMAGE="$1"
TAR="$2"

cleanup() {
  local rs=$?
  local d
  cd /
  for m in /mnt/part*; do
    umount "$m" 2> /dev/null || :
  done
  for d in $DEVS; do
    if [ -b "/dev/mapper/$d" ]; then
      dmsetup remove "/dev/mapper/$d" 2> /dev/null || :
    fi
    if [ -b /dev/"${d%p*}" ]; then
      losetup -d "/dev/${d%p*}" 2> /dev/null || :
    fi
    d="${d%p*}"
    if [ -b "/dev/loop/${d#*loop}" ]; then
      losetup -d "/dev/loop/${d#*loop}" 2> /dev/null || :
    fi
  done
  trap '' EXIT
  exit $rs
}

trap cleanup EXIT TERM HUP INT USR1 USR2 STOP CONT

# generate block devices from image file
DEVS="$(kpartx -rav "$IMAGE" | grep -oE 'loop[^ ]+' | sort -u)"
for dev in $DEVS; do
  part_no="${dev#loop*p}"
  mkdir -p "/mnt/part$part_no"
  mount -r "/dev/mapper/$dev" "/mnt/part$part_no"
done

if [ -z "$COMPRESSOR" ]; then
  COMPRESSOR="zstd"
fi

tar cf "$TAR" --xattrs --selinux --acls --numeric-owner -I "$COMPRESSOR" -C /mnt .

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$TAR"
