#!/bin/sh
set -e

IN="$1"
OUT="$2"

IMG="$(unrar l "$IN" | grep -o -E "[^ ]+[.]img")"

unrar p -ierr "$IN" "$IMG" > "$OUT"

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$OUT"
