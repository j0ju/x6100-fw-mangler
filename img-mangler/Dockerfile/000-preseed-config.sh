#!/bin/sh -e
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

PS4='> ${0##*/}: '
#set -x

#- apt
echo 'APT::Get::Update::SourceListWarnings::NonFreeFirmware "false";' > /etc/apt/apt.conf.d/no-bookworm-firmware.conf
sed -i -e '/Components/ s/main/main non-free contrib/' /etc/apt/sources.list.d/debian.sources

#- enable bash_completion globally on interactive sessions
echo 'case $- in *i*) . /etc/bash_completion ;; esac' >> /etc/bash.bashrc

#- add a sane gitconfig
cp /etc/gitconfig /root/.gitconfig
