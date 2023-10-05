# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

# set base, copy scripts & out-of-tree resources
FROM x6100:xiegu-v1.1.7-opt-alpine
COPY xiegu.mods/modded.Dockerfile/ /src/xiegu.mods/modded.Dockerfile

# set environment - all build containers inherit this
#ENV - none -

# run scripts that do the modifications steps in one layer
# * moving files around - see # copy scripts & outoftree resources above
# * adding stuff, etc
RUN set -e ;\
    : set -x ;\
  exec /bin/sh \
    /src/img-mangler/docker-build-helper.sh \
    /src/xiegu.mods/modded.Dockerfile
