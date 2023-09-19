# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
FROM x6100:Opt.Alpine.3.18 AS opt-alpine
FROM x6100:v1.1.7-vanilla

COPY --from=opt-alpine /tarballs /tarballs
RUN set -ex ;\
  for p in /tarballs/*.tar.gz; do \
    [ -r "$p" ] || continue ;\
    tar xzf "$p" -C /target ;\
  done
