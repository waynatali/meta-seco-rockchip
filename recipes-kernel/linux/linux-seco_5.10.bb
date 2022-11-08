DESCRIPTION = "Linux Kernel for Seco reference boards, based on Rockchip processors"

require recipes-kernel/linux/linux-yocto.inc
require linux-seco.inc

inherit freeze-rev

KERNEL_SRC ?= "git://git.seco.com/pub/rockchip/linux-seco-rk5.10.git;"
PROTOCOL ?= "protocol=ssh;"

REPO_USER ?= ""

SRCBRANCH = "develop"

KMETA = "kernel-meta"

SRC_URI = " \
	${KERNEL_SRC};branch=${SRCBRANCH};${PROTOCOL}${REPO_USER} \
	git://git.yoctoproject.org/yocto-kernel-cache;type=kmeta;name=meta;branch=yocto-${LINUX_VERSION};destsuffix=${KMETA} \
"

SRCREV = "f0795c0ea4ec02e4023f82c8ad4a407098e22f73"
SRCREV_meta = "4ee40666966cf3cb07c45a5e12b68952492e2efc"

KERNEL_VERSION_SANITY_SKIP = "1"
LINUX_VERSION ?= "5.10"

KERNEL_FEATURES:append = " features/kprobes/kprobes.scc"

COMPATIBLE_MACHINE = "seco-px30-d23"
