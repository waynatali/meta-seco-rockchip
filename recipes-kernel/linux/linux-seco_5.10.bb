DESCRIPTION = "Linux Kernel for Seco reference boards, based on Rockchip processors"

require recipes-kernel/linux/linux-yocto.inc
require linux-seco.inc

inherit freeze-rev

KERNEL_SRC ?= "git://git.seco.com/pub/rockchip/linux-seco-rk5.10.git;"
PROTOCOL ?= "protocol=ssh;"

REPO_USER ?= ""

SRCBRANCH = "develop"

SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH};${PROTOCOL}${REPO_USER}"
SRCREV = "7381e3c0a84e6a0733e56caace49a0c6549d69ee"

KERNEL_VERSION_SANITY_SKIP = "1"
LINUX_VERSION ?= "5.10"

COMPATIBLE_MACHINE = "seco-px30-d23"
