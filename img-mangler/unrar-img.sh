IN="$1"
OUT="$2"

IMG="$(unrar l "$IN" | grep -o -E "[^ ]+[.]img")"

unrar p -ierr "$IN" "$IMG" > "$OUT"
