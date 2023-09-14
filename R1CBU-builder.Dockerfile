FROM x6100:img-mangler

COPY R1CBU-builder   /src/R1CBU-builder

RUN set -ex ;\
  . /src/R1CBU-builder/prepare.sh ;\
  tar cf /workspace.tar.zst -C /workspace . -I zstd ;\
: # eo RUN

