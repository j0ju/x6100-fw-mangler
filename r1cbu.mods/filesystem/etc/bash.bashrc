# - /etc/profile -
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

export PATH="/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin"

case "$_GLOBAL_PROFILE_READ:$-" in
  yes:* ) ;;
  *:*i* )
    _GLOBAL_PROFILE_READ=yes
    [ ! -f /etc/profile ] || \
      . /etc/profile
    ;;
esac

