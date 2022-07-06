# SPDX-FileCopyrightText: SECO Spa
# SPDX-License-Identifier: Apache-2.0

DESCRIPTION = "rkdeveloptool gives you a simple way to read/write rockusb device."
DEPENDS = "libusb-native"
SRC_URI = "git://github.com/rockchip-linux/rkdeveloptool.git;protocol=https"
SRCREV = "46bb4c073624226c3f05b37b9ecc50bbcf543f5a"
S = "${WORKDIR}/git"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

inherit deploy autotools

BBCLASSEXTEND = "native"

do_configure () {
    cd ${S}
    aclocal
    autoreconf -i
    autoheader
    automake --add-missing
    oe_runconf $@
}

do_compile () {
    cd ${S}
    oe_runmake
}

do_install () {
    cd ${S}
    install -d ${D}${bindir}
    install -m 0755 rkdeveloptool ${D}${bindir}/
}

do_deploy () {
    install -m 0755 ${S}/rkdeveloptool ${DEPLOYDIR}/
    install -m 0644 ${S}/config.ini ${DEPLOYDIR}/
}

addtask deploy before do_build after do_install
