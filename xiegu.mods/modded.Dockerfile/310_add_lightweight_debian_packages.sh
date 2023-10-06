#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

# ----- use Debian Buster as donor for some lightweight packages
# ----- not a nice way, this works for that _small_ apps quite "okay-ish"
# Q: why? A: similar libc version
  mkdir -p /tmp/dpkg
  cd /tmp/dpkg
  wget -q \
    http://archive.debian.org/debian-archive/debian/pool/main/b/bsdiff/bsdiff_4.3-19_armhf.deb \
    http://archive.debian.org/debian-archive/debian/pool/main/n/ncurses/libtinfo5_5.9+20140913-1+deb8u3_armhf.deb \
    http://archive.debian.org/debian-archive/debian/pool/main/h/hexer/hexer_1.0.3-1_armhf.deb \
  # EO wget  

  DEBS=

  for deb in *.deb; do
    dir="${deb%%_*}"
    echo "I: adding $deb"
    dpkg-deb -x "$deb" "${dir}"
    rm -rf "$dir/usr/share"
    if [ -d  "$dir"/lib/arm-linux-gnueabihf ]; then
      mv "$dir"/lib/arm-linux-gnueabihf/* "$dir"/usr/lib
      rmdir "$dir"/lib/arm-linux-gnueabihf
    fi
    if [ -d  "$dir"/usr/lib/arm-linux-gnueabihf ]; then
      mv "$dir"/usr/lib/arm-linux-gnueabihf/* "$dir"/usr/lib
      rmdir "$dir"/usr/lib/arm-linux-gnueabihf
    fi
    tar cf - -C "$dir" . | tar xf - -C /target
    DEBS="$DEBS, $dir"
  done

# handle etckeeper and mdified configs
  cd /target/etc
  if git status --short | grep ^ > /dev/null; then
    chroot /target \
      etckeeper commit -m "add light weight debian packages: $DEBS"
  fi
