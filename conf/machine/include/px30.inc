# Copyright (c) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the MIT license (see COPYING.MIT for the terms)

SOC_FAMILY ?= "px30"
require conf/machine/include/rockchip-arm64-common.inc

MALI_GPU := "bifrost-g31"
MALI_VERSION := "rxp0"

IMAGE_FSTYPES += "wic.bmap"
BOOT_DEV ?= "emmc"
IMAGE_LINK_NAME = "${IMAGE_BASENAME}-${MACHINE}-${BOOT_DEV}"
