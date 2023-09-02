#!/bin/sh
set -e

IMAGE="$1"
TAR="$2"

cleanup() {
  local rs=$?
  local d
  cd /
  umount /mnt/boot 2> /dev/null || :
  umount /mnt/update 2> /dev/null || :
  umount /mnt 2> /dev/null || :
  umount /mntRO 2> /dev/null || :
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
DEVS="$(kpartx -rav "$1" | grep -oE 'loop[^ ]+' | sort -u)"
mkdir -p /mntRO

# mount and and generate filesystem structure without modifying original image
mount -r /dev/mapper/$(echo "$DEVS" | grep -Eo "loop[^ ]+p2") /mntRO
mount -t tmpfs tmpfs /mnt
tar cf - -C /mntRO --xattrs --selinux --acls --numeric-owner . | tar xf - -C /mnt --xattrs --selinux --acls --numeric-owner --atime-preserve
mkdir -p /mnt/boot
mount -r /dev/mapper/$(echo "$DEVS" | grep -Eo "loop[^ ]+p1") /mnt/boot
mkdir -p /mnt/update
mount -r /dev/mapper/$(echo "$DEVS" | grep -Eo "loop[^ ]+p3") /mnt/update
mount -o remount -r /mnt

if [ -z "$COMPRESSOR" ]; then
  COMPRESSOR="zstd"
fi

tar cf "$TAR" --xattrs --selinux --acls --numeric-owner -I "$COMPRESSOR" -C /mnt .
