# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

# set base, copy scripts & out-of-tree resources
FROM x6100:Opt.Alpine.3.18      AS opt-alpine
FROM x6100:r1cbu-v0.20.1-vanilla

COPY r1cbu-v0.20.1-opt-alpine.Dockerfile.d/ /src/r1cbu-v0.20.1-opt-alpine.Dockerfile.d/
# code re-use - house made - spagetti code yolonese ;)
COPY xiegu-v1.1.7-opt-alpine.Dockerfile.d/ /src/xiegu-v1.1.7-opt-alpine.Dockerfile.d/
COPY --from=opt-alpine /tarballs /tarballs

# set environment - all build containers inherit this
#ENV - none -

# run scripts that do the modifications steps in one layer
# * moving files around - see # copy scripts & outoftree resources above
# * adding stuff, etc
RUN set -e ;\
  export \
    SRC=/src/r1cbu-v0.20.1-opt-alpine.Dockerfile.d/ ;\
  exec \
    /bin/sh /src/img-mangler/docker-build-helper.sh $SRC
