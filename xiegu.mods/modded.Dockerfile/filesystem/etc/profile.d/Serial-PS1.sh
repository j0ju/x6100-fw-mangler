# /etc/profile.d/Serial-PS1.sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

# check whether we are on a serial tty and if so, add terminal resizing tweak to PS1
case "$(tty)" in
  /dev/ttyS[0-9] | /dev/ttyGS[0-9] | /dev/ttyAMA[0-9] )
    f__pretval() {
      set -- $? "$@"
      "${@:2}"
      return $1
    }
    f__resize() {
      IFS_BAK=$IFS
      IFS=$';\x1B['
      read -p $'\x1B7\x1B[r\x1B[999;999H\x1B[6n\x1B8' -d R -rst 1 _ _ LINES COLUMNS _ < /dev/tty &&
      stty cols $COLUMNS rows $LINES
      IFS=$IFS_BAK
    }
    PS1="$PS1"'$(f__pretval f__resize)'
    ;;
esac

