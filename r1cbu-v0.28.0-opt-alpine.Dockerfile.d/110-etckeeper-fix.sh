#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

# * fix something with test and the supplied dash/bash
# * mock needed getent functions

#- FAT finger solution
#echo "I: replace /bin/sh with /opt/alpine/busybox"
#  rm /target/bin/sh
#  ln -s ../opt/alpine/bin/busybox /target/bin/sh

#- minimal invasive solution
F=/target/etc/etckeeper/commit.d/50vcs-commit
cp -a "$F" "$F".$$
cat > "$F".$$ << 'EOF'
#!/opt/alpine/bin/busybox sh
set -e

getent() {
  local getent
  for getent in /usr/bin/getent /bin/getent; do
    if [ -x "$getent" ]; then
      getent "$@"
      return $?
    fi
  done
  case "$1" in
    passwd )
      grep ^$2: /etc/passwd
      ;;
    * )
      echo "E: mock up for missing getent binary failed."
      echo "E: patch for getent failed"
      exit 1
      ;;
  esac
}

# EO patch
EOF
cat "$F" >> "$F".$$
mv -f "$F".$$ "$F"

F="/target/$(chroot /target which /usr/bin/etckeeper)"
cp -a "$F" "$F".$$
cat > "$F".$$ << 'EOF'
#!/opt/alpine/bin/busybox sh
set -e

# EO patch
EOF
cat "$F" >> "$F".$$
mv -f "$F".$$ "$F"
