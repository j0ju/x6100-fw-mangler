# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

# set base, copy scripts & out-of-tree resources
FROM x6100:Xiegu-1.1.7.1.update
COPY xiegu.mods/vanilla.Dockerfile/ /src/xiegu.mods/vanilla.Dockerfile

# set environment - all build containers inherit this
#ENV - none -

# run scripts that do the modifications steps in one layer
# * moving files around - see # copy scripts & outoftree resources above
# * adding stuff, etc
RUN set -e ;\
    : set -x ;\
  exec /bin/sh \
    /src/img-mangler/docker-build-helper.sh \
    /src/xiegu.mods/vanilla.Dockerfile

CMD rm -f /target/etc/resolv.conf; cp /etc/resolv.conf /target/etc/resolv.conf; exec env HOME=/root SHELL=/bin/bash chroot /target /bin/bash -l
