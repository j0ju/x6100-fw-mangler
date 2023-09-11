FROM x6100:v1.1.7-opt-alpine

RUN set -ex ;\
  rm -f /target/linuxrc ;\
  : #

COPY mods /tmp/mods

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
    cd /target/etc/rc.d ;\
    mv \
      S70vsftpd S59snmpd S46ofono S48sntp S49ntp \
      disabled \
      ; \
    rm -f \
      /target/etc/rsyncd.conf \
      ; \
  : ----- add fs modifications ;\
    cd /tmp/mods ;\
    find . ! -type d | while read f; do \
      rm -f "/target/$f" ;\
      mkdir -p "/target/${f%/*}" ;\
      mv "$f" "/target/$f" ;\
    done ;\
    chroot /target /usr/local/sbin/update-rc ;\
    find /target/etc -name "*.old" -delete ;\
    echo "mediafs /media tmpfs mode=0755,nosuid,nodev 0 0" >> /target/etc/fstab ;\
    : rm -f /target/etc/udev/rules.d/*-auto-mount.rules ;\
  : ----- set new default password ;\
    ( echo "x6100"; echo "x6100"; echo ) | chroot /target passwd root ;\
  : ----- generate new boot script ;\
    ( cd /target/boot ;\
      mkimage -A arm -T script -d boot.u-boot boot.scr ;\
    ) ;\
  : #

