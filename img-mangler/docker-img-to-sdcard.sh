#!/bin/sh
set -e
set -x

#--- calculate image size
USAGE_KB="$(du -sk /target | { read kb _; echo $kb; })"


MIN_FREE_SPACE_KB="$((512*1024))" # 0.5GB in KB
#MIN_FREE_SPACE_KB="$((1024*1024))" # 1GB in KB
ROUND_UP_KB="$((512*1024))" # 0.5GB in KB
#ROUND_UP_KB="$((1024*1024))" # 1GB in KB

IMAGE_SIZE_KB=$(( USAGE_KB + MIN_FREE_SPACE_KB + ROUND_UP_KB ))
IMAGE_SIZE_KB=$(( ( IMAGE_SIZE_KB / ROUND_UP_KB ) * ROUND_UP_KB ))

IMAGE="$1"

: > $IMAGE
#--- write uboot for sdcard boot
dd if=sdcard.uboot+spl.img bs=1024 seek=8 of=$IMAGE
#--- generate sparse image
dd if=/dev/zero bs=1024 count=0 seek=$IMAGE_SIZE_KB of=$IMAGE
#--- partition it
sfdisk $IMAGE <<EOF
  label: dos
  type=83 start=2048 bootable
EOF

#--- mount image fs
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
DEVS="$(kpartx -av "$IMAGE" | grep -oE 'loop[^ ]+' | sort -u)"

P1="$(echo $DEVS | grep -E -o "[^ ]+p1")"
mkdir -p /mnt/part1

mkfs.ext4 -L x6100root /dev/mapper/$P1

mount -t ext4 /dev/mapper/$P1 /mnt/part1

#--- copy rootfs
tar cf - -C /target . | tar xf - -C /mnt/part1 --atime-preserve

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"
