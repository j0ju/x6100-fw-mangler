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
