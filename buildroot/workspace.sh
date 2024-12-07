#!/bin/sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

#--- settings
  set -e
  #set -x

  X6100_BR_GIT=https://github.com/gdyuldin/AetherX6100Buildroot.git

 #--- ensure workdir
  mkdir -p /workspace
  cd /workspace

  echo "GIT $PWD/AetherX6100Buildroot $X6100_BR_GIT"
  [ -d AetherX6100Buildroot/.git ] || \
    git clone --recurse-submodules $X6100_BR_GIT

#--- prepare repos for building
  cd /workspace/AetherX6100Buildroot
  echo "PREPARE BUILDROOT $PWD"
    sh br_config.sh

#--- build
#  cd build
#  make
