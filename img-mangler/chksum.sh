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

bin/D6100 "$TYPE"sum -c "$CHKSUMFILE" \
  && rs=$? || rs=$?

return $?
