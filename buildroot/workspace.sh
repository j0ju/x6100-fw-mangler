#!/bin/sh

#--- settings
  set -e
  set -x

  BUILDROOT_GIT=https://github.com/buildroot/buildroot.git
  #BUILDROOT_GITREV=tags/2022.11.3
  #BUILDROOT_GITREV=tags/2023.02.3
  BUILDROOT_GITREV=tags/2023.05.1

  X6100_BR_GIT=https://github.com/strijar/AetherX6100Buildroot.git
  X6100_BR_GITREV=remotes/origin/R1CBU

  X6100_GIT=https://github.com/strijar/x6100_gui.git
  X6100_GITREV=main

#--- ensure workdir
  mkdir -p /workspace
  cd /workspace

  [ -d AetherX6100Buildroot/.git ] || \
    git clone $X6100_BR_GIT
  cd AetherX6100Buildroot
  git co local || \
    git co -b local $X6100_BR_GITREV

  cd buildroot
  [ -d .git ] || \
    git clone $BUILDROOT_GIT .
  git co local || \
    git co -b local $BUILDROOT_GITREV

  cd /workspace
  [ -d x6100_gui/.git ] || \
    git clone $X6100_GIT
  cd x6100_gui
  git co local || \
    git co -b local $X6100_GITREV

#--- prepare repos for building
  cd /workspace/AetherX6100Buildroot
  if [ ! -f build/Makefile ]; then
    cp /src/buildroot/sun8i-r16-x6100_defconfig /workspace/AetherX6100Buildroot/br2_external/board/X6100/linux
    cp /src/buildroot/X6100_defconfig           /workspace/AetherX6100Buildroot/br2_external/configs/X6100_defconfig
    sh br_config.sh
  fi

#--- build
  #cd build
  #make