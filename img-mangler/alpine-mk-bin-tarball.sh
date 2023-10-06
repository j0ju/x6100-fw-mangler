#!/bin/sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
set -e

BIN="$1"
OUTPUT_DIR="$2"

NEW_PATH="${BIN#*:}"
BIN="${BIN%:$NEW_PATH}"
[ ! "$NEW_PATH" = "$BIN" ] || \
  NEW_PATH=
if [ -n "$NEW_PATH" ]; then
  mkdir -p "${NEW_PATH%/*}"
  ln "$BIN" "$NEW_PATH"
  BIN=$NEW_PATH
fi

EXE="$(which "$BIN")"
BINPKG="$OUTPUT_DIR/$(echo -n "${EXE#/}" | tr '/:' '_' ).bin.tar.gz"

mkdir -p "$OUTPUT_DIR"
echo "I: build $BINPKG"
FILES="${EXE#/}"
LIBS="$( \
  ldd "$EXE" 2> /dev/null 2>/dev/null |
  grep -oE "/[-+_a-zA-Z0-9./]+" |
  sort -u |
  while read lib; do
    echo ${lib#/}
      while [ -L "$lib" ]; do
        lib="$(cd "${lib%/*}"; realpath "$(readlink "$lib")")"
        echo ${lib#/}
      done
    done |
      sort -u
  )"; \
tar czf $BINPKG -C / $FILES $LIBS
if [ ! -s "$BINPKG" ]; then :
  echo "W: $BINPKG is empty, removing" >&2
  rm -f "$BINPKG"
  exit 1
fi
