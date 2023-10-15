#!/bin/sh
# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

#--- settings
  set -e
  #set -x

  X6100_BR_GIT=https://github.com/strijar/AetherX6100Buildroot.git
  X6100_BR_GITREV=remotes/origin/R1CBU

  X6100_GIT=https://github.com/strijar/x6100_gui.git
  X6100_GITREV=main

#--- ensure workdir
  mkdir -p /workspace
  cd /workspace

  echo "GIT $PWD/AetherX6100Buildroot $X6100_BR_GIT"
  [ -d AetherX6100Buildroot/.git ] || \
    git clone -b R1CBU --recurse-submodules $X6100_BR_GIT
  cd AetherX6100Buildroot
  git co local || \
    git co -b local $X6100_BR_GITREV

  cd /workspace
  echo "GIT $PWD/x6100_gui $X6100_GIT"
  [ -d x6100_gui/.git ] || \
    git clone --recurse-submodules $X6100_GIT
  cd x6100_gui
  git co local || \
    git co -b local $X6100_GITREV

#--- prepare repos for building
  cd /workspace/AetherX6100Buildroot
  echo "PREPARE BUILDROOT $PWD"
  if [ ! -f build/Makefile ]; then
    cp /src/buildroot/sun8i-r16-x6100_defconfig /workspace/AetherX6100Buildroot/br2_external/board/X6100/linux
    cp /src/buildroot/X6100_defconfig           /workspace/AetherX6100Buildroot/br2_external/configs/X6100_defconfig
    sh br_config.sh
  fi

#--- build
  #cd build
  #make
