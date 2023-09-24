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

# ----- rework init system, to have it more traditional
RUN set -ex ;\
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
    : #

# ----- disable services
RUN set -ex ;\
    mkdir /target/etc/rc.d/disabled ;\
    cd /target/etc/rc.d ;\
    mv \
      S70vsftpd S59snmpd S46ofono S48sntp S49ntp \
      disabled \
      ; \
    : #

# ----- add fs modifications
RUN set -ex ;\
    cd /tmp/mods/filesystem ;\
    find . ! -type d | while read f; do \
      rm -f "/target/$f" ;\
      mkdir -p "/target/${f%/*}" ;\
      mv "$f" "/target/$f" ;\
    done ;\
    chroot /target /usr/local/sbin/update-rc ;\
    : #

# ----- use Debian Buster as donor for some lightweight packages
# ----- not a nice way, this works for that _small_ apps quite "okay-ish"
# Q: why? A: similar libc version
RUN set -ex ;\
  mkdir -p /tmp/dpkg ; \
  cd /tmp/dpkg ; \
  wget \
    http://archive.debian.org/debian-archive/debian/pool/main/b/bsdiff/bsdiff_4.3-19_armhf.deb \
    http://archive.debian.org/debian-archive/debian/pool/main/n/ncurses/libtinfo5_5.9+20140913-1+deb8u3_armhf.deb \
    http://archive.debian.org/debian-archive/debian/pool/main/h/hexer/hexer_1.0.3-1_armhf.deb \
  ; \
  for deb in *.deb; do \
    dir="${deb%%_*}" ; \
    dpkg-deb -x "$deb" "${deb%%_*}" ;\
    rm -rf "$dir/usr/share" ;\
    if [ -d  "$dir"/lib/arm-linux-gnueabihf ]; then \
      mv "$dir"/lib/arm-linux-gnueabihf/* "$dir"/usr/lib ;\
      rmdir "$dir"/lib/arm-linux-gnueabihf ;\
    fi ;\
    if [ -d  "$dir"/usr/lib/arm-linux-gnueabihf ]; then \
      mv "$dir"/usr/lib/arm-linux-gnueabihf/* "$dir"/usr/lib ;\
      rmdir "$dir"/usr/lib/arm-linux-gnueabihf ;\
    fi ;\
    tar cf - -C "$dir" . | tar xf - -C /target ;\
  done ;\
  : #

# ----- APP font and colour modifications via binary patches ;\
RUN set -ex ;\
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

# ----- modify usb mmc automounting
# ----- disable usb mmc automounting
RUN set -ex ;\
    echo "mediafs /media tmpfs mode=0755,nosuid,nodev 0 0" >> /target/etc/fstab ;\
    mkdir -p /target/etc/udev/rules.d/disabled ;\
    mv -f /target/etc/udev/rules.d/*-auto-mount.rules /target/etc/udev/rules.d/disabled ;\
    : #
# ----- remove GPIB IEEE488 development leftovers
RUN set -ex ;\
    grep gpib /target//etc/udev/rules.d/*.rules -l | xargs rm -f ;\
    rm -rf \
      /target/usr/share/linux-gpib-user \
      ;\
  :

# ----- set new default password
RUN set -ex ;\
    ( echo "x6100"; echo "x6100"; echo ) | chroot /target passwd root ;\
  : #

# ----- set shell to /bin/bash
RUN set -ex ;\
    sed -i -e '/^root/ s|/bin/sh|/bin/bash|' /target/etc/passwd ;\
  : #

# ----- set home to /tmp and care about dot-files on bootup
RUN set -ex ;\
    sed -i -e '/^root/ s|/root|/tmp|' /target/etc/passwd ;\
    echo "#!/bin/sh" > /target/etc/init.d/root-dotfiles ;\
    echo "#- user config files for root in temp legen" >> /target/etc/init.d/root-dotfiles ;\
    echo "cp -a /root/.[a-zA-Z0-9]* /tmp 2> /dev/null" >> /target/etc/init.d/root-dotfiles ;\
    chmod 0755 /target/etc/init.d/root-dotfiles ;\
    ln -s ../init.d/root-dotfiles /target/etc/rc.d/S99root-dotfiles ;\
  : #

# ----- cleanup
RUN set -ex ;\
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
