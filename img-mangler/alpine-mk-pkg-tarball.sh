#! /bin/sh

set -e

PKG=$1
OUTPUT_DIR=$2

mkdir -p "$OUTPUT_DIR"
BINPKG="$OUTPUT_DIR/$PKG.pkg.tar.gz"
echo "I: build $BINPKG"

FILES="$( apk info -L "$PKG" | sed -e '1 d' -e '/^$/ d' -e 's|^|/|' | tr '\n\r' ' ' )"
LIBS="$(
  for EXE in $FILES; do
    ldd "$EXE" 2> /dev/null 1>&2 || \
      continue
    ldd "$EXE"
  done | \
    grep -oE "/[-+_a-zA-Z0-9./]+" | \
    sort -u | \
    while read lib; do
      echo $lib
      while [ -L "$lib" ]; do
        lib="$(cd "${lib%/*}"; realpath "$(readlink "$lib")")"
        echo $lib
      done
    done | \
    sort -u
)"

#echo >&2 $PKG: $FILES
#echo >&2 $PKG: $LIBS

if [ -n "$FILES$LIBS" ]; then
  tar czf $BINPKG $FILES $LIBS
fi

if [ ! -s "$BINPKG" ]; then :
  echo "W: $BINPKG is empty, removing" >&2
  rm -f "$PKG.bin.tar"
fi

