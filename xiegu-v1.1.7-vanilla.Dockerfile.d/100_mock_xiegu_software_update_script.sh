#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

echo "I: run post installation by mocking official update script"
  chroot /target /bin/sh -ec " \
    # set -x
      cd /usr/share/emmc_sources
      MMC_VALID=yes
    # ----- fake environment
      mkdir -p /mnt
      rm -rf /mnt/emmc_p1 /mnt/emmc_p2
      ln -s /boot /mnt/emmc_p1
      ln -s / /mnt/emmc_p2
    # -----  mock some commands and environment
      fdisk() { echo 'mmcblk2p1 _ _ _ 48M' ; echo 'mmcblk2p2 _ _ _ 7.2G' ; }
      dd() { :; }
      mount() { :; }
      tar() { :; }
      pv() { :; }
      rm() { :; }
    # ----- run install script
      set +e
      . ./install_emmc.sh
  " # eo chroot

  rm -rf /target/tmp /target/run
  mkdir /target/tmp /target/run
  chmod 1777 /target/tmp
  chmod 0755 /target/run
