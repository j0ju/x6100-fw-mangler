# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
FROM x6100:r1cbu-v0.17.1-opt-alpine

RUN set -ex ;\
  rm -f /target/linuxrc ;\
  : #

COPY r1cbu.mods /tmp/mods

RUN set -ex ;\
  : ----- rework init system a bit ; \
    mkdir /target/etc/rc.d ;\
    cd /target/etc/init.d ;\
    for rcd in [KS][0-9][0-9]*; do \
      initd="${rcd##???}" ;\
      initd="${initd##-[0-9]-}" ;\
      op="${rcd%${rcd#?}}" ;\
      level="${rcd%${initd}}" ;\
      level="${level#?}" ;\
      mv "$rcd" "$initd"; \
      ln -s "../init.d/${initd}" "../rc.d/${rcd}" ;\
    done ; \
    sed -i -e 's|init.d|rc.d|' rcS rcK ;\
  : ----- disable services ; \
    mkdir /target/etc/rc.d/disabled ;\
    : TODO ;\
  : ----- add fs modifications ;\
    cd /tmp/mods/filesystem ;\
    find . ! -type d | while read f; do \
      rm -f "/target/$f" ;\
      mkdir -p "/target/${f%/*}" ;\
      mv "$f" "/target/$f" ;\
    done ;\
    chroot /target /usr/local/sbin/update-rc ;\
  : ----- modify usb mmc automounting ;\
    echo "mediafs /media tmpfs mode=0755,nosuid,nodev 0 0" >> /target/etc/fstab ;\
    sed -i -e '/[/]mnt/ d' /target/etc/fstab ;\
  : ----- set new default password ;\
    ( echo "x6100"; echo "x6100"; echo ) | chroot /target passwd root ;\
  : ----- set shell to /bin/bash ;\
    sed -i -e '/^root/ s|/bin/sh|/bin/bash|' /target/etc/passwd ;\
  : ----- cleanup  ;\
    find /target/etc -name "*.old" -delete ;\
    rm -rf \
      /target/etc/rsyncd.conf \
      /target/etc/logrotate.d \
      /target/etc/nginx \
      /target/mnt/emmc_* \
      /target/mnt/update \
      /target/boot/zimage \
      ; \
  : #


