FROM x6100:v1.1.7-opt-alpine

RUN set -ex ;\
  rm -f /target/linuxrc ;\
  : #

COPY xiegu.mods/filesystem /tmp/mods

RUN set -ex ;\
  : ----- install bluetooth hack ; \
    git clone https://github.com/busysteve/X6100-Bluetooth-Audio.git /target/tmp/bthack ;\
    chroot /target sh -x -c "cd /tmp/bthack; . ./install.sh" ;\
    rm -rf /tmp/bthack ;\
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
    cd /target/etc/rc.d ;\
    mv \
      S70vsftpd S59snmpd S46ofono S48sntp S49ntp \
      disabled \
      ; \
  : ----- add fs modifications ;\
    cd /tmp/mods ;\
    find . ! -type d | while read f; do \
      rm -f "/target/$f" ;\
      mkdir -p "/target/${f%/*}" ;\
      mv "$f" "/target/$f" ;\
    done ;\
    chroot /target /usr/local/sbin/update-rc ;\
  : ----- modify usb mmc automounting ;\
    echo "mediafs /media tmpfs mode=0755,nosuid,nodev 0 0" >> /target/etc/fstab ;\
  : ----- disable usb mmc automounting ;\
    mkdir -p /target/etc/udev/rules.d/disabled ;\
    mv -f /target/etc/udev/rules.d/*-auto-mount.rules /target/etc/udev/rules.d/disabled ;\
  : ----- set new default password ;\
    ( echo "x6100"; echo "x6100"; echo ) | chroot /target passwd root ;\
  : ----- generate new boot script ;\
    ( cd /target/boot ;\
      mkimage -A arm -T script -d boot.u-boot boot.scr ;\
    ) ;\
  : ----- cleanup  ;\
    find /target/etc -name "*.old" -delete ;\
    rm -rf \
      /target/etc/rsyncd.conf \
      /target/etc/logrotate.d \
      /target/etc/nginx \
      /target/mnt/emmc_* \
      /target/mnt/update \
      ; \
  : #


