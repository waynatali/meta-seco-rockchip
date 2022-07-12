DESCRIPTION = "Linux Kernel for Seco reference boards, based on Rockchip processors"

require recipes-kernel/linux/linux-yocto.inc
require linux-seco.inc

inherit freeze-rev

KERNEL_SRC ?= "git://git.seco.com/pub/rockchip/linux-seco-rk5.10.git;"
PROTOCOL ?= "protocol=ssh;"

REPO_USER ?= ""

SRCBRANCH = "develop"

SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH};${PROTOCOL}${REPO_USER}"
SRCREV = "79603a5c5c5873344d3fa683ec418286b4c56b0f"

KERNEL_VERSION_SANITY_SKIP = "1"
LINUX_VERSION ?= "5.10"

COMPATIBLE_MACHINE = "seco-px30-d23"
