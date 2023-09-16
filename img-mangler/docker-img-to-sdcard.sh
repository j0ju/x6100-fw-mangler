#!/bin/sh
set -e
#set -x

#---
UPDATE=no
if [ "$1" = --update ]; then
  UPDATE=yes
  shift
fi

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
dd if=uboot.img bs=1024 seek=8 of=$IMAGE status=none
#--- generate sparse image
dd if=/dev/zero bs=1024 count=0 seek=$IMAGE_SIZE_KB of=$IMAGE status=none
#--- partition it
echo "PARTITION"
sfdisk $IMAGE > /dev/null <<EOF
  label: dos
  2: type=83 start=2048 bootable
EOF

#--- mount image fs
cleanup() {
  local rs=$?
  local d
  [ $rs = 0 ] || \
    rm -f "$IMAGE"
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

P2="$(echo $DEVS | grep -E -o "[^ ]+p2")"
mkdir -p /mnt/

echo "MKFS"
mkfs.ext4 -q -L x6100root /dev/mapper/$P2

mount -t ext4 /dev/mapper/$P2 /mnt

#--- copy rootfs
echo "COPY"
tar cf - -C /target . | tar xf - -C /mnt --atime-preserve

if [ "$UPDATE" = yes ]; then
  ( cd img-mangler/update
    UPDATE_SH=flash-emmc.sh
    find . -type f | while read f; do
      if [ -f "/mnt/$f" ]; then
        mv "/mnt/$f" "/mnt/$f.$UPDATE_SH"
      fi
      cp "$f" "/mnt/$f"
    done
    chmod 0755 "/mnt/$UPDATE_SH"
  )
fi

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"
