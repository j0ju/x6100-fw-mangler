#!/bin/sh
set -eu

#- helpers
  usage() {
    echo
    echo "usage:"
    echo "  ${0##*/} <device-to-clone-to>"
    echo
    exit 1
  }
  setX() {
    ( set -x;
      "$@"
    )
  }
  CLEANUP_PROCS=
  cleanup() {
    local proc
    local rs=$?
    for proc in $CLEANUP_PROCS; do
      "$proc"
    done
    trap '' EXIT INT QUIT TERM HUP
    return $rs
  }
  trap cleanup EXIT INT QUIT TERM HUP

#- config
  export LC_ALL=C LANG=C
  SRC_DEV="$( mount | awk '$0 ~" / " {print $1}' )"
	case "$SRC_DEV" in
		sdp[0-9] | sd[a-z]p[0-9] )
			SRC_DEV="${SRC_DEV%[0-9]}"
		  ;;	
		*p[0-9] )
			SRC_DEV="${SRC_DEV%p[0-9]}"
			;;
		*[0-9] )
			SRC_DEV="${SRC_DEV%[0-9]}"
			;;
		* )
    	echo "E: could not find source device, found '$SRC_DEV', ABORT"
			exit 1
			;;
	esac

#- get temporary dir
  TMPDIR="$(mktemp -d)"
  CLEANUP_PROCS="$CLEANUP_PROCS cleanup_tmpdir"
  cleanup_tmpdir() {
    setX rmdir "$TMPDIR"
  }

#- get device to backup to
  BAK_DEV="${1:-}"
	if [ "$SRC_DEV" = "$BAK_DEV" ]; then
    echo "E: backup device '$BAK_DEV' cannot be the same device as the source '$SRC_DEV', ABORT"
    usage
    exit 1
	fi >&2
  if ! [ -b "$BAK_DEV" ]; then
    echo "E: '$BAK_DEV' does not exist or is not a block device, ABORT"
    echo "I: provide a valid destination block device in \$1"
    usage
    exit 1
  fi >&2

  p=
  case "$BAK_DEV" in
    *[0-9] ) p=p ;;
  esac

  BOOT_DEV="$BAK_DEV$p"1
  ROOT_DEV="$BAK_DEV$p"2

#- wipe bak drive
  echo "I: wipe '$BAK_DEV'"
  wipefs -af "$BAK_DEV$p"[0-9]* 2> /dev/null || :
  wipefs -af "$BAK_DEV"
  sleep 3

#- copy partition table
  echo "I: replicating partition table from $SRC_DEV to $BAK_DEV"
## MBR ##
  #- copy MBR
    sfdisk --dump "$SRC_DEV" | \
		  grep -v ^label-id: | \
      sfdisk "$BAK_DEV" 1> /dev/null
    sleep 3
	

#-   helpers for cleanup
  BOOT_DIR="$TMPDIR"
  ROOT_DIR=
  cleanup_boot_mount() {
    while ( set -x; umount "$BOOT_DEV" 2> /dev/null; )  do :; done
  }
  cleanup_root_mount() {
    local i
    for i in 1 2 3; do
      cat /proc/mounts | grep " $TMPDIR" | cut -f2 -d" " | sort -r | while read where; do
        setX umount "$where" || :
      done
    done || :
    while ( set -x; umount "$ROOT_DEV" 2> /dev/null; )  do :; done
  }
  CLEANUP_PROCS="cleanup_boot_mount cleanup_root_mount $CLEANUP_PROCS"

#-   create /
  echo "I: create / on $ROOT_DEV"
  #setX mkfs.f2fs "$ROOT_DEV"
  setX mkfs.ext4 "$ROOT_DEV"

##-   create /boot
  echo "I: create /boot on $BOOT_DEV"
  setX mkfs.vfat "$BOOT_DEV"

#-   assemble clone
  echo "I: assemble clone"
  mount "$ROOT_DEV" "$TMPDIR"
  mkdir -p "$TMPDIR"/boot
  setX rsync -a -x -t -O -J -H -A -X -S --delete-after /boot/ "$TMPDIR"/boot
  setX rsync -a -x -t -O -J -H -A -X -S --delete-after / "$TMPDIR"
	
#- update cmdline and fstab to new UUID
  echo "I: adapt /etc/fstab"
  BOOT_UUID="$( blkid -o value -s UUID "$BOOT_DEV" )"
  ROOT_UUID="$( blkid -o value -s UUID "$ROOT_DEV" )"
  ROOT_PARTUUID="$( blkid -o value -s PARTUUID "$ROOT_DEV" )"
  echo "   /       UUID=$ROOT_UUID PARTUUID=$ROOT_PARTUUID"
  echo "   /boot   UUID=$BOOT_UUID"
cat > "$TMPDIR/etc/fstab" << EOF
# /etc/fstab
# <file system>	<mount pt>	<type>	<options>	<dump>	<pass>
UUID=$ROOT_UUID /				ext4	rw,noauto	0	1
UUID=$BOOT_UUID /boot 	vfat	ro,noauto	0	1

proc		/proc		proc	defaults	0	0
devpts		/dev/pts	devpts	defaults,gid=5,mode=620,ptmxmode=0666	0	0
tmpfs		/dev/shm	tmpfs	mode=0777	0	0
tmpfs		/tmp		tmpfs	mode=1777	0	0
tmpfs		/run		tmpfs	mode=0755,nosuid,nodev	0	0
sysfs		/sys		sysfs	defaults	0	0

# eof
EOF

#- generate boot script and kernel
  mount "$BOOT_DEV" "$TMPDIR"/boot
	echo "I: generate boot script"
cat > "$TMPDIR/boot/boot.u-boot" << EOF
echo "mmc\$devnum: boot from external MMC"
setenv bootargs console=ttyS0,115200 root=PARTUUID=$ROOT_PARTUUID rootwait panic=10 fbcon=rotate:3 video=VGA:480x800
fatload mmc \$devnum:1 0x46000000 zImage
fatload mmc \$devnum:1 0x49000000 \${fdtfile}
bootz 0x46000000 - 0x49000000
EOF
	mkimage -A arm -T script -d "$TMPDIR/boot/boot.u-boot" "$TMPDIR/boot/boot.scr"
  cat /boot/sun8i-r16-x6100.dtb > "$TMPDIR/boot/sun8i-r16-x6100.dtb"
  cat /boot/zImage > "$TMPDIR/boot/zImage"
	echo x6100-cloned > "$TMPDIR/etc/hostname"

#- FINISH
finished() {
echo "I: backup script reached its end, without unknown errors"
}
CLEANUP_PROCS="$CLEANUP_PROCS finished"
