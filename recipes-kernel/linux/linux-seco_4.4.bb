DESCRIPTION = "Linux Kernel for Seco reference boards, based on Rockchip processors"

require recipes-kernel/linux/linux-yocto.inc
require linux-seco.inc

inherit freeze-rev

KERNEL_SRC ?= "git://git.seco.com/pub/rockchip/linux-seco-rk4.4.git"
PROTOCOL ?= "protocol=https"

REPO_USER ?= ""

SRCBRANCH = "develop"

SRC_URI = "${KERNEL_SRC};branch=${SRCBRANCH};${PROTOCOL};${REPO_USER}"
SRCREV = "645936464a1d6641c2bab5686045d4fce281fdd3"

KERNEL_VERSION_SANITY_SKIP = "1"
LINUX_VERSION ?= "4.4"

COMPATIBLE_MACHINE = "(seco-px30-d23)"
