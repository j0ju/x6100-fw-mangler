BIN="$1"
OUTPUT_DIR="$2"

PREFIX="${BIN#*:}"
BIN="${BIN#:$PREFIX}"
mkdir -p "$OUTPUT_DIR"
BINPKG="$OUTPUT_DIR/$BIN.bin.tar.gz"
echo "I: build $BINPKG"
EXE="$(which "$BIN")"
FILES="$EXE"
LIBS="$( \
  ldd "$EXE" 2> /dev/null 2>/dev/null |
  grep -oE "/[-+_a-zA-Z0-9./]+" |
  sort -u |
  while read lib; do
    echo $lib
      while [ -L "$lib" ]; do
        lib="$(cd "${lib%/*}"; realpath "$(readlink "$lib")")"
        echo $lib
      done
    done |
      sort -u
  )"; \
tar czf $BINPKG $FILES $LIBS
if [ ! -s "$BINPKG" ]; then :
  echo "W: $BINPKG is empty, removing" >&2
  rm -f "$PKG.bin.tar"
fi
