# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

# set base, copy scripts & out-of-tree resources
FROM x6100:r1cbu-v0.28.0-opt-alpine
COPY       r1cbu-v0.28.0-modded.Dockerfile.d/ /src/r1cbu-v0.28.0-modded.Dockerfile.d/
# a bit of code reuse
COPY       xiegu-v1.1.8-modded.Dockerfile.d/  /src/xiegu-v1.1.8-modded.Dockerfile.d/

# set environment - all build containers inherit this
#ENV - none -

# run scripts that do the modifications steps in one layer
# * moving files around - see # copy scripts & outoftree resources above
# * adding stuff, etc
RUN set -e ;\
  export \
    SRC=/src/r1cbu-v0.28.0-modded.Dockerfile.d/ ;\
  exec \
    /bin/sh /src/img-mangler/docker-build-helper.sh $SRC
