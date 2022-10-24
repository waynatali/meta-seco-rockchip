# Copyright (C) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the MIT license (see COPYING.MIT for the terms)

SRC_URI:append:seco-px30-d23 = " \
	git://github.com/murata-wireless/cyw-fmac-fw.git;protocol=https;nobranch=1;name=murata-fw;destsuffix=murata-fw \
	git://github.com/murata-wireless/cyw-fmac-nvram.git;protocol=https;nobranch=1;name=murata-nvram;destsuffix=murata-nvram \
"
SRCREV_murata-fw    = "ba140e42c3320262fc52e185c3af93eeb10117df"
SRCREV_murata-nvram = "8710e74e79470f666912c3ccadf1e354d6fb209c"
SRCREV_FORMAT = "linux-firmware-murata"

# Install addition firmwares
do_install:append:seco-px30-d23() {
	install -m 0644 ${WORKDIR}/murata-fw/cyfmac43455-sdio.bin ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.bin
	install -m 0644 ${WORKDIR}/murata-fw/cyfmac43455-sdio.1MW.clm_blob ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.clm_blob
	#Unset bit 27 in boardflags3 and it will select either internal or external clock signal.
	sed -i 's/boardflags3.*/boardflags3=0x40200100/g' ${WORKDIR}/murata-nvram/cyfmac43455-sdio.1MW.txt
	install -m 0644 ${WORKDIR}/murata-nvram/cyfmac43455-sdio.1MW.txt ${D}${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.txt
}

FILES:${PN}-bcm43455:append:seco-px30-d23 = " \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.clm_blob \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.txt \
	${nonarch_base_libdir}/firmware/brcm/brcmfmac43455-sdio.bin \
"
RDEPENDS:${PN}-bcm43455:remove:seco-px30-d23 = " ${PN}-cypress-license "
