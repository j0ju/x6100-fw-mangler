# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
FROM x6100:xiegu-v1.1.7-opt-alpine

RUN set -ex ;\
  rm -f /target/linuxrc ;\
  : #

COPY xiegu.mods /tmp/mods

# ----- install bluetooth stream hack ; \
#RUN set -ex ;\
#    git clone https://github.com/busysteve/X6100-Bluetooth-Audio.git /target/tmp/bthack ;\
#    chroot /target sh -x -c "cd /tmp/bthack; . ./install.sh" ;\
#    rm -rf /tmp/bthack

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
      ;

RUN set -ex ;\
  : ----- add fs modifications ;\
    cd /tmp/mods/filesystem ;\
    find . ! -type d | while read f; do \
      rm -f "/target/$f" ;\
      mkdir -p "/target/${f%/*}" ;\
      mv "$f" "/target/$f" ;\
    done ;\
    chroot /target /usr/local/sbin/update-rc ;\
    :

RUN set -ex ;\
  : ----- APP font and colour modifications via binary patches ;\
  SHA1SUM="$( sha1sum /target/usr/app_qt/x6100_ui_v100 | ( read sum _; echo $sum ))" ;\
  if [ -r /tmp/mods/x6100_ui_v100/$SHA1SUM.bsdiff40 ]; then \
    bspatch \
      /target/usr/app_qt/x6100_ui_v100          \
      /target/usr/app_qt/x6100_ui_v100.$$       \
      /tmp/mods/x6100_ui_v100/$SHA1SUM.bsdiff40 ;\
    mv /target/usr/app_qt/x6100_ui_v100.$$ /target/usr/app_qt/x6100_ui_v100 ;\
    chmod 0755 /target/usr/app_qt/x6100_ui_v100 ;\
  fi ;\
  :

RUN set -ex ;\
  : ----- modify usb mmc automounting ;\
    echo "mediafs /media tmpfs mode=0755,nosuid,nodev 0 0" >> /target/etc/fstab ;\
  : ----- disable usb mmc automounting ;\
    mkdir -p /target/etc/udev/rules.d/disabled ;\
    mv -f /target/etc/udev/rules.d/*-auto-mount.rules /target/etc/udev/rules.d/disabled ;\
  : ----- remove GPIB IEEE488 development leftovers ;\
    grep gpib /target//etc/udev/rules.d/*.rules -l | xargs rm -f ;\
    rm -rf \
      /target/usr/share/linux-gpib-user \
      ;\
  :

RUN set -ex ;\
  : ----- set new default password ;\
    ( echo "x6100"; echo "x6100"; echo ) | chroot /target passwd root ;\
  : ----- set shell to /bin/bash ;\
    sed -i -e '/^root/ s|/bin/sh|/bin/bash|' /target/etc/passwd ;\
  :

RUN set -ex ;\
  : ----- cleanup  ;\
    find /target/etc -name "*.old" -delete ;\
    find /target/etc -name "*-" -delete ;\
    rmdir /target/etc/* 2> /dev/null || :;\
    rm -rf \
      /target/etc/rsyncd.conf \
      /target/etc/logrotate.d \
      /target/etc/nginx \
      /target/mnt/emmc_* \
      /target/mnt/update \
      ; \
  : #
