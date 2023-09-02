IN="$1"
OUT="$2"

IMG="$(unzip -l "$IN" | grep -o -E "[^ ]+[.]img")"

unzip -p "$IN" "$IMG" > "$OUT"
