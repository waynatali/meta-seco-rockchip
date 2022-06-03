# Copyright (C) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the MIT license (see COPYING.MIT for the terms)

FILESEXTRAPATHS:prepend:seco-px30-d23 := "${THISDIR}/files:"

SRC_URI:append:seco-px30-d23 = " \
	git://github.com/murata-wireless/cyw-fmac-fw.git;protocol=https;nobranch=1;name=murata-fw;destsuffix=murata-fw \
    	git://github.com/murata-wireless/cyw-fmac-nvram.git;protocol=https;nobranch=1;name=murata-nvram;destsuffix=murata-nvram \
	file://firmware/rockchip/dptx.bin \
"
SRCREV_murata-fw    = "ba140e42c3320262fc52e185c3af93eeb10117df"
SRCREV_murata-nvram = "8710e74e79470f666912c3ccadf1e354d6fb209c"
SRCREV_FORMAT = "linux-firmware-murata"

# Install addition firmwares
do_install:append:seco-px30-d23() {
	cp -r ${WORKDIR}/firmware ${D}${nonarch_base_libdir}/
	if [ -e ${WORKDIR}/license-destdir/linux-firmware/LICENSE.rockchip ]; then
		install -m 0644 ${WORKDIR}/license-destdir/linux-firmware/LICENSE.rockchip ${D}${nonarch_base_libdir}/firmware/
	fi
	install -m 0644 ${WORKDIR}/murata-fw/cyfmac43455-sdio.bin ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.bin
	install -m 0644 ${WORKDIR}/murata-fw/cyfmac43455-sdio.1MW.clm_blob ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.clm_blob
	install -m 0644 ${WORKDIR}/murata-nvram/cyfmac43455-sdio.1MW.txt ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.txt
}
PACKAGES:prepend:seco-px30-d23 = " \
	${PN}-rk-cdndp \
	${PN}-rockchip-license \
"
LICENSE:append:seco-px30-d23 = " & LICENSE.rockchip"
LIC_FILES_CHKSUM:append:seco-px30-d23 = " file://${RKBASE}/licenses/LICENSE.rockchip;md5=d63890e209bf038f44e708bbb13e4ed9"

LICENSE:${PN}-rk-cdndp = "LICENSE.rockchip"
LICENSE:${PN}-rockchip-license = "LICENSE.rockchip"

FILES:${PN}-rockchip-license = " \
	${nonarch_base_libdir}/firmware/LICENCE.rockchip \
"
FILES:${PN}-rk-cdndp = " \
	${nonarch_base_libdir}/firmware/rockchip/dptx.bin \
"
FILES:${PN}-bcm43455:append:seco-px30-d23 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.clm_blob \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.txt \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.bin \
"

RDEPENDS:${PN}-rk-cdndp = "${PN}-rockchip-license"
RDEPENDS:${PN}-bcm43455:remove:seco-px30-d23 = " ${PN}-cypress-license "
INSANE_SKIP:append:seco-px30-d23 = " host-user-contaminated"
