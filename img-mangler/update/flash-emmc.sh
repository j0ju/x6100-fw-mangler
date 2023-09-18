#!/bin/sh
set -e
set -x

DEV=/dev/mmcblk2
PART=/dev/mmcblk2p2

exec 5<>/dev/tty0
>&5 clear

#TODO:
#  * backup previous data for restore
#  * restore backups

>&5 echo "UBOOT $DEV"
dd if=/dev/mmcblk0 of="$DEV" bs=1024 skip=8 seek=8 count=640 status=none
>&5 echo "PARTITION"
sfdisk "$DEV" > /dev/null <<EOF
  label: dos
  2: type=83 start=2048 bootable
EOF

>&5 echo "MKFS $DEV"
mkfs.ext4 -q -F -L x6100 "$PART"
PARTUUID=
eval "$(blkid -o export "$PART")"
if [ -z "$PARTUUID" ]; then
  >&5 echo "E: PARTUUID of data partition not found"
  exit 1
fi

>&5 echo "MOUNT $PART PARTUUID=$PARTUUID"
mkdir -p      /media/orig
mount   /     /media/orig --bind
mkdir -p      /media/target
mount   $PART /media/target

>&5 echo "COPY ROOTFS $PART"
tar   cf - -C /media/orig   .  | \
  tar xf - -C /media/target

>&5 echo "CLEANUP AFTER UPDATE $PART"
find /media/target -name "*.${0##*/}" -type f | while read f; do
  mv "$f" "${f%.${0##*/}}"
done


>&5 echo "UPDATE UBOOT SCRIPT $PART $PARTUUID"
( cd /media/target/boot
  sed -i -r -e "/setenv[ ]+rootdev / s/rootdev.*/rootdev PARTUUID=$PARTUUID/" boot.u-boot
  mkimage -A arm -T script -d boot.u-boot boot.scr > /dev/null
)

#TODO:
#  * backup and restore prev data

rm -f /media/target/"$0"

df /media/target
>&5 df /media/target

umount /media/orig
umount /media/target

>&5 echo "update finished!"
>&5 echo "power off in 3"
sleep 1
>&5 echo "power off in 2"
sleep 1
>&5 echo "power off in 1"
sleep 1
>&5 echo "power off in 0"
poweroff
