#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

PATCH_DIR="/src/xiegu.mods/modded.Dockerfile/x6100_ui_v100"

SHA1SUM="$( sha1sum /target/usr/app_qt/x6100_ui_v100 | ( read sum _; echo $sum ))" ;\
echo "I: patch app if we have a patch for x6100_ui_v100"

PATCH="$PATCH_DIR/$SHA1SUM.bsdiff40"
if [ -r "$PATCH" ]; then \
  echo "I: patch foung for sha1sum:$SHA1SUM"
  bspatch \
    /target/usr/app_qt/x6100_ui_v100          \
    /target/usr/app_qt/x6100_ui_v100.$$       \
    "$PATCH"
  mv /target/usr/app_qt/x6100_ui_v100.$$ /target/usr/app_qt/x6100_ui_v100
  chmod 0755 /target/usr/app_qt/x6100_ui_v100
else
  echo "I: patch NOT found for sha1sum:$SHA1SUM"
  exit 1
fi
