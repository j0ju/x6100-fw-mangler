FROM x6100:Alpine-armhf-3.18 AS source

FROM scratch
COPY --from=source /target/ /

ENV SRC=/lib/ld-musl-armhf.so.1
ENV NEW_LIBPATH=/opt/alpine/lib
ENV OUTPUT_DIR=/tarballs

ENV BINPKGS=" \
  mkimage \
  ss \
  nsenter unshare \
  ip \
"

ENV PKGS=" \
  ncurses ncurses-terminfo ncurses-terminfo-base \
  wavemon htop procps psmisc usbutils hwids-usb \
  e2fsprogs e2fsprogs-extra \
  u-boot-tools \
  mtr tcpdump \
  iproute2 \
  file libmagic \
  sed \
  vim vim-common lua5.4 \
  mc \
  curl wget \
  xxd xz zstd \
  pv \
  strace ltrace lsof \
  coreutils \
  tmux screen minicom \
  jq \
  rsync \
  wipefs \
  bash-completion iproute2-bash-completion procs-bash-completion util-linux-bash-completion mtr-bash-completion \
"
  #sed file \

# install packages
RUN set -ex; \
  apk add --no-cache sed file ;\
  apk add --no-cache $PKGS ;\
: # eo RUN

# modify ld loader and filesystem layout
RUN set -ex ; \
    ORIGIN_LIBPATH="$(strings "$SRC"  | grep ^/lib:)" ;\
    NEEDLE="^/lib:$(echo -n ${NEW_LIBPATH#?????} | tr 'a-zA-Z0-9/:-' '.' )." ;\
    REGEX="s|$NEEDLE|$NEW_LIBPATH"'\x0'"|" ;\
    DST="/opt/alpine/lib/${SRC##*/}" ; \
  :;\
  : ----- patch ld.so ; \
    mkdir -p "${NEW_LIBPATH%/*}" ; \
    strings  "$SRC" | tee "/${SRC##*/}".orig.strings | sed    -r -e "$REGEX" > "/${SRC##*/}".strings ; \
    cat      "$SRC" | tee "/${SRC##*/}".orig         | sed -z -r -e "$REGEX" > "/${SRC##*/}" ; \
    chmod 0755 "/${SRC##*/}" ; \
  :;\
  : ----- prepare substitution ld.so ; \
    cp -a /usr/lib "${NEW_LIBPATH%/*}" ; \
    rm -f \
      /opt/alpine/lib/libcrypto.so.3 \
      /opt/alpine/lib/libssl.so.3 \
      ; \
    cp -a /lib     "${NEW_LIBPATH%/*}" ; \
    mv "/${SRC##*/}" "$DST" ; \
    mv "/${SRC##*/}"* "$NEW_LIBPATH" ; \
  :;\
    ln -sf "$DST" "/lib/${SRC##*/}" ; \
    rm -rf /lib /usr/lib ; \
    $DST /bin/busybox ln -s "${NEW_LIBPATH}" /usr/lib ; \
    $DST /bin/busybox ln -s "${NEW_LIBPATH}" /lib ; \
  : ; \
: # eo RUN

COPY img-mangler/alpine-mk-bin-tarball.sh /
COPY img-mangler/alpine-mk-pkg-tarball.sh /

# create tarballs from binaries
RUN set -ex ; \
  : --- dump of tarballs ;\
    for BIN in $BINPKGS; do \
      sh -e /alpine-mk-bin-tarball.sh $BIN $OUTPUT_DIR; \
    done; \
: # eo RUN

# create tarballs from packages
RUN set -ex ; \
  : --- dump of tarballs ;\
    for BIN in $PKGS; do \
      sh -e /alpine-mk-pkg-tarball.sh $BIN $OUTPUT_DIR; \
    done; \
: # eo RUN

