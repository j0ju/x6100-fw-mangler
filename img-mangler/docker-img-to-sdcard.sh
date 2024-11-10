#!/bin/sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
set -e

#---
UPDATE=no
ROUND_UP=1024
MIN_FREE=59512
while [ -n "$1" ]; do
  case "$1" in
    --update )
      UPDATE=yes
      shift
      ;;
    --round-up )
      ROUND_UP="$2"
      shift
      shift
      ;;
    --min-free )
      MIN_FREE="$2"
      shift
      shift
      ;;
    * ) break ;;
  esac
done

#--- calculate image size
USAGE_KB="$(du -sk /target | { read kb _; echo $kb; })"


MIN_FREE_SPACE_KB="$(( MIN_FREE * 1024 ))" # 0.5GB in KB
ROUND_UP_KB="$(( ROUND_UP * 1024 ))" # 0.5GB in KB

IMAGE_SIZE_KB=$(( USAGE_KB + MIN_FREE_SPACE_KB ))
IMAGE_SIZE_KB=$(( ( IMAGE_SIZE_KB / ROUND_UP_KB +1 ) * ROUND_UP_KB ))

IMAGE="$1"

: > $IMAGE
echo "UBOOT install"
#--- write uboot for sdcard boot
dd if=uboot.img bs=1024 seek=8 of=$IMAGE status=none
#--- generate sparse image
dd if=/dev/zero bs=1024 count=0 seek=$IMAGE_SIZE_KB of=$IMAGE status=none
#--- partition it
echo "FDISK"
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
  for m in /mnt/part* /mnt; do
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
trap cleanup EXIT TERM HUP INT USR1 USR2
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

#--- adapt uboot scripts
PARTUUID=
echo "UBOOT generate config"
eval "$(blkid -o export /dev/mapper/$P2)"
if [ -z "$PARTUUID" ]; then
  echo "E: PARTUUID of data partition not found"
  exit 1
fi
if [ -f /mnt/boot/boot.u-boot ]; then
  ( cd /mnt/boot
    sed -i -r -e "/setenv[ ]+rootdev / s/rootdev.*/rootdev PARTUUID=$PARTUUID/" boot.u-boot
    mkimage -A arm -T script -d boot.u-boot boot.scr > /dev/null
  )
fi

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$IMAGE"
