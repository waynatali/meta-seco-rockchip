meta-seco-rockchip
===============
Yocto BSP layer for the Seco's reference boards based on Rockchip SOC
  - wiki <http://opensource.rock-chips.com/wiki_Main_Page>.

This README file contains information on building and booting
meta-seco-rockchip BSP layer.  Please see the corresponding sections below
for details.


Yocto Project Compatible
========================

The BSP contained in this layer is compatible with the Yocto Project
as per the requirements listed here:

  https://www.yoctoproject.org/webform/yocto-project-compatible-registration


Tested Hardware
================

This layer has been tested with the following MACHINE variables:

  - `seco-px30-d23` Juno (SBC-D23) board


Dependencies
============

This layer depends on:

  URI: git://git.openembedded.org/bitbake
  branch: master

  URI: git://git.openembedded.org/meta-openembedded
  layers: meta-oe
  branch: kirkstone


Configuration
=============

1. Clone the `meta-seco-rockchip` layer to your project directory.

2. Add the `meta-seco-rockchip` layer to `conf/bblayers.conf`

```bitbake
	BBLAYERS += "path/to/meta-seco-rockchip"
```
3. Configure the variable MACHINE in your local.conf.

```bitbake
	MACHINE ?= "seco-px30-d23"
```
 or while using bitbake:
 
```bash
	MACHINE="seco-px30-d23" bitbake core-image-minimal
```


Building meta-seco-rockchip BSP Layer
==========================================
You should then be able to build an image as such:

```bash
	bitbake core-image-minimal
```
At the end of a successful build, you should have an .wic image in /path/to/yocto/build/tmp/deploy/images/\<MACHINE\>/


Booting your Device
=============

Under Linux, you can use upgrade_tool: <http://opensource.rock-chips.com/wiki_Upgradetool> to flash the image:

1. Put your device into rockusb mode: <http://opensource.rock-chips.com/wiki_Rockusb>

2. If it's maskrom rockusb mode, try to enter miniloader rockusb mode:

```bash
	sudo upgrade_tool UL \<IMAGE PATH\>/loader.bin
```
Note: In the above instruction a path to upgrade_tool binary is in the variable PATH!

You can run the commands from /path/to/yocto/build/tmp/deploy/images/\<MACHINE\>/ directory:

```bash
	sudo ./upgrade_tool UL px30_loader_v1.11.115.bin
```
3. Flash only the uboot.img and trust.img into emmc.

```bash
	sudo ./upgrade_tool DI -u uboot.img 
	sudo ./upgrade_tool DI -t trust.img
```
4. Flash the wic image (uboot and rootfs) into emmc.

```bash
	sudo ./upgrade_tool wl 0 \<IMAGE PATH\>/\<IMAGE NAME\>.wic
```
5. You can also run ./flash_d23.sh

```bash
	chmod u+x flash_d23.sh
	./flash_d23.sh -h     #for the usage details
```
Credits
=======

Based on the `meta-rockchip` layer from [rockchip][rockchip].

[rockchip]: https://github.com/JeffyCN/meta-rockchip
