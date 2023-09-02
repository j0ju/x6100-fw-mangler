#!/bin/sh
set -e

CHKSUM="$2"
FILE="$1"

TYPE="${CHKSUM%%:*}"
CHKSUM="${CHKSUM##*:}"

case "$TYPE" in
  md5 | sha1 | sha256 ) ;; # OK
  * )
    echo "E: unknown checksum $CHKSUM for $FILE" >&2
    exit 1
    ;;
esac

CHKSUMFILE=".deps/$FILE.$TYPE"sum
echo "$CHKSUM $FILE" > "$CHKSUMFILE"

docker run --rm -v $PWD:/src -w /src x6100:img-mangler "$TYPE"sum -c "$CHKSUMFILE" \
  && rs=$? || rs=$?

return $?
