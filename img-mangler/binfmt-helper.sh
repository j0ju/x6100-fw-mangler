#!/bin/sh
set -e
#set -x

# sets up binfmt emulation using qemu-user-static for docker environments, where it is not available per default
# eg. Rancher Desktop
# Should work on Rancher Desktop or Ubuntu 22.04 or Debian Bullseye/Bookworm
# it is not reboot persitend

# magic to register qemu for arm (Little Endian) binaries for the X6100 if not configured o
magic='\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00'
mask='\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff'
family=arm
flags=POCF

binfmt_register_arm() {
  # test if already registered
  if nsenter -at 1 -- /bin/sh -c "[ -f '/proc/sys/fs/binfmt_misc/qemu-$family' ]"; then
    echo "I: qemu-$family already registered"
    return 0
  else
    # this is the binary from the img-mangler docker image
    qemu="/usr/bin/qemu-$family-static"

    # copy image for to host in case of LIMA
    # this does nothing if you are on Debian or Ubuntu a-like distributions if qemu-user-static is installed
    # TODO: what about other distributions like arch?
    nsenter -at 1 -- /bin/sh -e -c "
      if [ ! -x '${qemu}' ]; then
        mkdir -p '${qemu%/*}'
        cat > '${qemu}'
        chmod 0755 '${qemu}'
      fi
    " < "$qemu"

    # register arm helper, if not already registered, as the name qemu-arm is a standard used, it should do nothing if already registered
    echo ":qemu-$family:M::$magic:$mask:${qemu}:$flags" | \
      nsenter -at 1 -- /bin/sh -e -c "cd /proc/sys/fs/binfmt_misc; [ -f qemu-$family ] || cat > register"
  fi
}

binfmt_unregister_arm() {
  nsenter -at 1 -- /bin/sh -c "
    if [ -f '/proc/sys/fs/binfmt_misc/qemu-$family' ]; then
      echo '${0##*/}: unregister qemu-$family'
      echo -1 > '/proc/sys/fs/binfmt_misc/qemu-$family'
    fi
  "
}

binfmt_reset_all() {
  nsenter -at 1 -- /bin/sh -c '
    cd /proc/sys/fs/binfmt_misc
    for f in qemu-*; do
      [ -f "$f" ] || continue
      echo "'"${0##*/}"': unregister $f"
      echo -1 > "$f"
    done
  '
}

status() {
  nsenter -at 1 -- /bin/sh -c '
    cd /proc/sys/fs/binfmt_misc
    echo "'"${0##*/}"': registered binfmts"
    for f in qemu-*; do
      if [ ! -f "$f" ]; then
        echo "    NONE"
        break
      fi
      echo "    $f:"
      sed "s/^/        /" < "$f"
    done
  '
}

usage() {
  echo "${0##*/} [register | unregister | reset-all ]" >&2
  exit 1
}

case "$1" in
  register | reg | r )
     binfmt_register_arm
     ;;
  unregister | unreg | u )
     binfmt_unregister_arm
     ;;
  reset-all)
     binfmt_reset_all
     ;;
  status | s )
     status
     ;;
  * )
    usage
    ;;
esac

