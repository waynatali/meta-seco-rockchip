# SPDX-FileCopyrightText: SECO Spa
# SPDX-License-Identifier: Apache-2.0

SUMMARY = "Command line tool to flash bootloader and rootfs images"
DESCRIPTION = "Rkdeveloptool is an opensource version of Rockchip upgrade_tool to communicate with Rockusb devices"
HOMEPAGE = "http://opensource.rock-chips.com/wiki_Rkdeveloptool"
LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://license.txt;md5=ea9445d9cc03d508cf6bb769d15a54ef"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "git://github.com/rockchip-linux/rkdeveloptool.git;protocol=https;branch=master;"
SRC_URI += " \
	file://0002-fix-format-truncation-warning.patch \
	"
SRCREV = "46bb4c073624226c3f05b37b9ecc50bbcf543f5a"

inherit autotools pkgconfig deploy native

DEPENDS = "libusb1-native"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

do_deploy() {
	install -m 0755 ${B}/rkdeveloptool ${DEPLOYDIR}
}

addtask deploy before do_build after do_install
