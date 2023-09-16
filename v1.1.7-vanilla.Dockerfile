FROM x6100:X6100-1.1.7.1.update

# extract update tarball to /
RUN set -ex ;\
  mv /target /target.old ;\
  mkdir /target ;\
  tar xf /target.old/part3/rootfs.tar -C /target ;\
  rm -rf /target.old ;\
: # eo RUN

# mock post installation
RUN set -ex ;\
    chroot /target /bin/sh -exc " \
      cd /usr/share/emmc_sources ;\
      MMC_VALID=yes ;\
    : ----- fake environment ;\
      mkdir -p /mnt ;\
      rm -rf /mnt/emmc_p1 /mnt/emmc_p2 ;\
      ln -s /boot /mnt/emmc_p1 ;\
      ln -s / /mnt/emmc_p2 ;\
    : -----  mock some commands and environment ;\
      fdisk() { echo 'mmcblk2p1 _ _ _ 48M' ; echo 'mmcblk2p2 _ _ _ 7.2G' ; }; \
      dd() { :; } ;\
      mount() { :; } ;\
      tar() { :; } ;\
      pv() { :; } ;\
      rm() { :; } ;\
    : ----- run install script ;\
      set +e ;\
      . ./install_emmc.sh ;\
    "





CMD rm -f /target/etc/resolv.conf; cp /etc/resolv.conf /target/etc/resolv.conf; exec env HOME=/root SHELL=/bin/bash chroot /target /bin/bash -l
