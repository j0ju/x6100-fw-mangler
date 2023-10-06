# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

# This docker file generates a modified Alpine Linux. 
#
# The most important (dirty hack!) patch is moving the libary search path to /opt/alpine/lib, 
# so we relocate coliding libraries from Alpines Userland.
#
# Aftwards it dumps specific binaries and packages to tarballs, that can
# later be extracted without conflicts to the Userland of Xiegu or R1CBU
# assuming that we add only software that is not present in the original
# image.
#

# set source, copy in files and patches
FROM x6100:Alpine-armhf-3.18 AS source

FROM scratch
COPY --from=source /target/ /

COPY img-mangler/alpine-mk-bin-tarball.sh /src/img-mangler/
COPY img-mangler/alpine-mk-pkg-tarball.sh /src/img-mangler/
COPY img-mangler/docker-build-helper.sh /src/img-mangler/
COPY Opt.Alpine.3.18.Dockerfile.d /src/Opt.Alpine.3.18.Dockerfile.d

# set environment - all build containers inherit this
ENV OUTPUT_DIR=/tarballs

# run scripts that do the modifications steps in one layer
# * moving files around - see # copy scripts & outoftree resources above
# * adding stuff, etc
RUN set -e ;\
    : set -x ;\
  for f in /src/Opt.Alpine.3.18.Dockerfile.d/[0-9]*.*; do \
    [ -x "$f" ] || continue ;\
    echo "executing $f" >&2;\
    "$f" ;\
  done
