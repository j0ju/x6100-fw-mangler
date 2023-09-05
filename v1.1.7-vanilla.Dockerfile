FROM x6100:X6100-1.1.7.update

RUN set -ex ;\
  mv /target /target.old ;\
  mkdir /target ;\
  tar xf /target.old/part3/rootfs.tar -C /target ;\
  rm -rf /target.old ;\
: # eo RUN

CMD rm -f /target/etc/resolv.conf; cp /etc/resolv.conf /target/etc/resolv.conf; HOME=/root SHELL=/bin/bash chroot /target /bin/bash
