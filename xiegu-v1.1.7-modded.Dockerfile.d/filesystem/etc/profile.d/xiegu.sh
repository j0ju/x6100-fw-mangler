# - /etc/profile.d/xiegu.sh

#--- set default environment variables used by xiegu software
  export PATH="$PATH:/usr/share/support"
  export XGRADIO_TMPDIR="/usr/tmp/xgradio"

#--- framebuffer and eGL settings for QT
  # I don't know how to change the default DPI
  # this physical size barely works
  export QT_QPA_EGLFS_PHYSICAL_WIDTH=78
  export QT_QPA_EGLFS_PHYSICAL_HEIGHT=130

  # we use ATOMIC functions here
  export QT_QPA_EGLFS_KMS_ATOMIC=1

  # egl screen rotation
  export QT_QPA_EGLFS_ROTATION=90

  # eglfs_kms config files
  export QT_QPA_EGLFS_KMS_CONFIG=/etc/qtkmsconfig.json

  # eglfs input devices config
  # export QT_QPA_GENERIC_PLUGINS=libinput
  # export QT_QPA_EVDEV_KEYBOARD_PARAMETERS=grab=1
  # export QT_QPA_EVDEV_MOUSE_PARAMETERS=grab=1
  # export QT_QPA_EGLFS_NO_LIBINPUT=1

  export QT_QPA_PLATFORM=eglfs
  export QT_QPA_PLATFORM_PLUGIN_PATH=/usr/lib/qt/plugins
  export QT_QPA_FONTDIR=/usr/share/fonts
  export XDG_RUNTIME_DIR=/tmp

#--- time zone, default UTC
  export TZ=UTC

