# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

FROM x6100:Opt.Alpine.3.18 AS alpine

  env ALPINE_BINARIES " \
    busybox \
    sfdisk \
    mkimage \
    blkid \
    wipefs \
    mkfs.ext4 \
    mke2fs \
  "

  # create tarballs from binaries
  RUN set -e; \
    : set -x; \
    : --- dump of tarballs ; \
      rm -rf /tarballs ; \
      mkdir /tarballs ; \
      for BIN in $ALPINE_BINARIES; do \
        sh -e /src/img-mangler/alpine-mk-bin-tarball.sh $BIN /tarballs; \
      done; \
  : # eo RUN

FROM x6100:img-mangler

  COPY multiboot /tmp/mods

  COPY --from=alpine /tarballs /tarballs
  RUN set -e; \
    : set -x; \
    mkdir \
      /target/proc \
      /target/etc \
      /target/dev \
      /target/bin \
      /target/tmp \
      /target/sys \
      /target/mnt \
      /target/media \
      ;\
    ln -s . /target/usr ;\
    ln -s bin /target/sbin ;\
    ln -s ../proc/self/mounts /target/etc/mtab ;\
    for p in /tarballs/*.tar.gz; do \
      [ -r "$p" ] || continue ;\
      tar xzf "$p" -C /target/ ;\
    done ;\
    chroot /target/ /bin/busybox --install -s /bin ;\
    : ;\
    cd /tmp/mods ;\
    find . ! -type d | while read f; do \
      rm -f "/target/$f" ;\
      mkdir -p "/target/${f%/*}" ;\
      mv "$f" "/target/$f" ;\
    done ;\
   : # eo RUN

# if in multiboot image /$x6100_multiboot/ has no /boot with kernel and .dtb
# the generated image will fail and fall back to boot rom eMMC.
#
# ----- EXAMPLE
  #RUN set -ex ;\
  #  cd /target ;\
  #  ln -s Xiegu Default ;\
  #  ln -s R1CBU Button1 ;\
  #  ln -s armbian Button2 ;\
  #  ln -s YetAnother Button3 ;\
  #: # eo RUN

# vim: foldmethod=indent
