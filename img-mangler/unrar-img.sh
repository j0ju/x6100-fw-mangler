#!/bin/sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE
set -e

IN="$1"
OUT="$2"

IMG="$(unrar l "$IN" | grep -o -E "[^ ]+[.]img")"

unrar p -ierr "$IN" "$IMG" > "$OUT"

[ -z "$OWNER" ] || \
  chown "$OWNER${GROUP:+:$GROUP}" "$OUT"
