# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
FROM x6100:xiegu-v1.1.7-modded AS xiegu

FROM x6100:r1cbu-v0.17.1-modded AS r1cbu

FROM x6100:multiboot

  COPY --from=xiegu /target /target/Xiegu
  COPY --from=r1cbu /target /target/R1CBU

  RUN set -ex ;\
    cd /target ;\
    ln -s Xiegu Default ;\
    ln -s R1CBU Button1 ;\
    ln -s Xiegu Button2 ;\
    ln -s Xiegu Button3 ;\
  : # eo RUN

# vim: foldmethod=indent
