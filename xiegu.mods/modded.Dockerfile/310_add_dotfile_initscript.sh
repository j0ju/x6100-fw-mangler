#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

echo "I: set home to /tmp and care about dot-files on bootup"
  sed -i -e '/^root/ s|/root|/tmp|' /target/etc/passwd
  echo "#!/bin/sh" > /target/etc/init.d/root-dotfiles
  echo "#- user config files for root in temp legen" >> /target/etc/init.d/root-dotfiles
  echo "cp -a /root/.[a-zA-Z0-9]* /tmp 2> /dev/null" >> /target/etc/init.d/root-dotfiles
  chmod 0755 /target/etc/init.d/root-dotfiles 
  ln -s ../init.d/root-dotfiles /target/etc/rc.d/S99root-dotfiles
