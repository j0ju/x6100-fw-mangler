#!/bin/sh
set -x
#exec 1>& /dev/tty0

DEV=/dev/mmcblk2
PART=/dev/mmcblk2p1

dd if=/dev/mmcblk0 of="$DEV" bs=1024 skip=8 seek=8 count=640 status=none
sfdisk "$DEV" > /dev/null <<EOF
  label: dos
  2: type=83 start=2048 bootable
EOF

mkdir -p /media/orig
mkdir -p /media/target

mkfs.ext4 -q -y -L x6100 "$PART"

mount --bind /              /media/orig
mount        /dev/mmcblk2p1 /media/target

tar   cf - -C /media/orig   .  | \
  tar xf - -C /media/target

find /media/target -name "*.${0##*/}" -type f | while read f; do
  mv "$f" "${f%.${0##*/}}"
done

rm -f /media/target/"$0"

#TODO:
#  * backup and restore prev data

echo "update finished!" 1>&/dev/tty0
echo "power off in 3" 1>&/dev/tty0
sleep 1
echo "power off in 2" 1>&/dev/tty0
sleep 1
echo "power off in 1" 1>&/dev/tty0
sleep 1
echo "power off in 0" 1>&/dev/tty0
poweroff
