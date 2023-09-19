# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
FROM x6100:R1CBU-v0.17.1.sdcard

RUN set -ex ;\
  mv /target /target.old ;\
  mv /target.old/part2 /target ;\
  cp -a /target.old/part1/* /target/boot ;\
  rm -rf /target.old ;\
: # eo RUN

CMD rm -f /target/etc/resolv.conf; cp /etc/resolv.conf /target/etc/resolv.conf; exec env HOME=/root SHELL=/bin/bash chroot /target /bin/bash -l
