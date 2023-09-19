# X6100 image mangler

 It takes X6100 flashable firmware images and creates a modified image or MMC bootable images via Docker.
 It uses qemu-user-static if needed to run code for foreign architectures.

## Motivation
 * make playing around with this device easier
 * easy integrating modifications
 * make modifications reproducible
 * ease debugging

## Features
 * generates a runable SDCard image with some modidications with an new partition layout
 * generates a runable update image on SDCard with some modifications with a new partition layout
 * integrates some more helper utils from Alpine into stock images

## `Don't`s
 No warranty, I will not be responsible for what ever you do with these generated images.
 They might break your device,it might eletrocute you, be warned. Act safe and sane.
 Only transmit in frequency ranges you are allowed to transmit, check for a clean HF of your device.
 I advise not distributing images generated this way, they contain copyrighted material.

# Requirements
 * Docker
 * `qemu-user-static` with a proper `binfmt` config, although if not available un your platform there is a small helper in the tools section.

## OSX
 Rancher Desktop or Docker Desktop fulfill this requirements.
 Homebrew might be handy.
 With Rancher Desktop you might need to execute the script `bin/binfmt-helper` before it works.

## Ubuntu/Debian
 * Docker Community edition
 * ...

# Usage

## Docker

 General usage

 * `make` - generates all Docker images
 * `make url` - Downloads all SDCard and update images
 * `make clean` - cleans up the directory

### Images

 * v1.1.7-modded - Xiegu orignal patched, add more userland tools to rootfs
 * r1cbu-v0.17.1-modded - alternative of R1CBU, rootfs extended
 * multiboot - boots per default v1.1.7-modded, If you keep the left-most-button pressed until you see a changed boot logo of the R1CBU firmware to boot it.


#### tl:dr Workflow

 * Archiv -> Image -> TarDump -> Dockerimage --> ... modding --> desired state of /target in image
 * Dockerimage `Name` --> `name.sdcard.img`
 * Dockerimage `Name` --> `name.update.img`

 eg.
 * `make v1.1.7-modded.sdcard.img` - generates a modded image of the original Xiegu Firmware
 * `make r1cbu-v0.17.1-modded.sdcard.img` - the same for the R1CBU OpenSource firmware

 * `make v1.1.7-modded.update.img` - generates a update image for installing it into the devies's eMMC
 * `make r1cbu-v0.17.1-modded.update.img` - the same for the R1CBU OpenSource firmware

 * `make multiboot.sdcard.img` - this is an image with latest Xiegu and R1CBU Firmware in one. 
 * `make multiboot.update.img` - the same but for writing on the eMMC

#### Patches

 The modded Xiegu image includes this patches:
 * patch https://github.com/busysteve/X6100-Bluetooth-Audio - disable for now
 * added a bluetoothd startup script from https://github.com/strijar/x6100_bt_patch
 * the GUI APP for v1.1.7.1 is colour patched - cyan text colour instead of red (thx to DB2ZW)
 * disable automounting of random USB or MMC hotplug devices for now

### ./config and ./config.example
 ...

### Under the hood

 The make file creates at first a docker image x6100:img-mangler with needed tools.
 Afterwards the sources from the .url files are downloaded and extracted.
 The resulting update images from Xiegu or R1BCU are then copied into the contents of /target of a docker image for later modifications.
 The modified contents then could be used to generate update images or images to be run from sdcard.
 With binfmt under Linux with docker you can even enter the Image as it would run on the x6100, of course without a GUI.

### Debugging

 `make V=1`

# Tools

 A short description about the tools in ./bin

 If you have a running envrc setup, you can use the .envrc to  have ./bin included in your PATH.

 * `D6100` - enter the mangling docker container with the source tree mounted in /src
 * `buildroot` - enter container with prepared buildroot environment
 * `binfmt-helper` - this install qemu-user-static and some binfmt signatures to enable running arm code on your workstation for development

## You have a fresh unknown image and wants to inspect its contents?

 * copy it to unknown-beauty.img into this directory
 * type `make unknown-beauty.tar`

 This depacks the image to the tar file `unknown-beauty.tar` for easier use.

# Plans

 * provide further settings and channels for the Xiegu original app
 * provide further settings and channels for the R1CBU app
 * rescue settings from Xiegu and R1CBU on image flash and restore
 * use stripped down version of ansible-openwrt (https://github.com/gekmihesg/ansible-openwrt) to configure or modify an running system on a X6100 or to backup settings.

