FROM x6100:Opt.Alpine.3.18 AS alpine

  env ALPINE_BINARIES " \
    busybox \
    sfdisk \
  "

  # create tarballs from binaries
  RUN set -ex ; \
    : --- install packages ;\
      apk add \
        sfdisk ;\
    : --- dump of tarballs ;\
      rm -rf /tarballs ;\
      mkdir /tarballs ;\
      for BIN in $ALPINE_BINARIES; do \
        sh -e /alpine-mk-bin-tarball.sh $BIN /tarballs; \
      done; \
  : # eo RUN

FROM x6100:v1.1.7-modded AS xiegu

FROM x6100:r1cbu-v0.17.1-modded AS r1cbu

FROM x6100:img-mangler

  COPY multiboot /tmp/mods

  COPY --from=alpine /tarballs /tarballs
  RUN set -ex ;\
    for p in /tarballs/*.tar.gz; do \
      [ -r "$p" ] || continue ;\
      tar xzf "$p" -C /target ;\
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

  COPY --from=xiegu /target /target/xiegu
  COPY --from=r1cbu /target /target/r1cbu

# vim: foldmethod=indent
