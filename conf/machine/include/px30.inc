# Copyright (c) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the MIT license (see COPYING.MIT for the terms)

SOC_FAMILY ?= "px30"
require conf/machine/include/rockchip-arm64-common.inc

MALI_GPU := "bifrost-g31"
MALI_VERSION := "g2p0"

IMAGE_FSTYPES += "wic.bmap"
BOOT_DEV ?= "emmc"
IMAGE_LINK_NAME = "${IMAGE_BASENAME}-${MACHINE}-${BOOT_DEV}"

# Install regulatory DB in /lib/firmware for kernel to load
IMAGE_INSTALL:append = " wireless-regdb-static"

# The source image of the Rauc bundle has the following name
# scheme: RAUC_SLOT_system - MACHINE . RAUC_SLOT_system[fstype]
# see oniro-bundle-base.bb for more details
IMAGE_POSTPROCESS_COMMAND:append = " link_rauc_src_image;"
link_rauc_src_image() {
        ln -sf "${IMAGE_LINK_NAME}.${ROOT_FSTYPE}" \
                "${IMGDEPLOYDIR}/${IMAGE_BASENAME}-${MACHINE}.${ROOT_FSTYPE}"
}
