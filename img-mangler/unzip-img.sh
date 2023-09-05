#!/bin/sh
set -e

IN="$1"
OUT="$2"

IMG="$(unzip -l "$IN" | grep -o -E "[^ ]+[.]img")"

unzip -p "$IN" "$IMG" > "$OUT"

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$OUT"
