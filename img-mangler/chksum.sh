#!/bin/sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
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
[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$CHKSUMFILE"

if ! ./bin/D6100 "$TYPE"sum -c "$CHKSUMFILE"; then
  chksum="$(./bin/D6100 "$TYPE"sum "$FILE" | cut -f1 -d" " )"
  echo "E: checksum for $FILE does not match."
  echo "E: Expected $CHKSUM $TYPE."
  echo "E: It was   $chksum"
fi >&2
