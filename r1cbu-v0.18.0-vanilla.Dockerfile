# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

# set base, copy scripts & out-of-tree resources
FROM x6100:R1CBU-v0.18.0.sdcard
COPY r1cbu-v0.18.0-vanilla.Dockerfile.d/ /src/r1cbu-v0.18.0-vanilla.Dockerfile.d/

# set environment - all build containers inherit this
#ENV - none -
CMD rm -f /target/etc/resolv.conf; cp /etc/resolv.conf /target/etc/resolv.conf; exec env HOME=/root SHELL=/bin/bash chroot /target /bin/bash -l

# run scripts that do the modifications steps in one layer
# * moving files around - see # copy scripts & outoftree resources above
# * adding stuff, etc
RUN set -e ;\
  export \
    SRC=/src/r1cbu-v0.18.0-vanilla.Dockerfile.d/ ;\
  exec \
    /bin/sh /src/img-mangler/docker-build-helper.sh $SRC
