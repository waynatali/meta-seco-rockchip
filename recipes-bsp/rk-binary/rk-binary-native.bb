# Copyright (C) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the MIT license (see COPYING.MIT for the terms)

inherit freeze-rev deploy native

DESCRIPTION = "Rockchip binary tools"

LICENSE = "LICENSE.rockchip"
LIC_FILES_CHKSUM = "file://${RKBASE}/licenses/LICENSE.rockchip;md5=d63890e209bf038f44e708bbb13e4ed9"

SRC_URI = " \
	git://github.com/JeffyCN/mirrors.git;protocol=https;branch=rkbin;name=rkbin \
	git://github.com/JeffyCN/mirrors.git;protocol=https;branch=tools;name=tools;destsuffix=git/extra \
"

PV:append = "+git${SRCPV}"

SRCREV_rkbin = "750302a720d6074ead976a8822ed38c7bdd341bf"
SRCREV_tools = "3009c707fdef358230b0d672dc19df8164c2e595"
SRCREV_FORMAT ?= "rkbin_tools"

S = "${WORKDIR}/git"

INSANE_SKIP:${PN} = "already-stripped"

# The pre-built tools have different link loader, don't change them.
UNINATIVE_LOADER := ""

do_install () {
	install -d ${D}/${bindir}

	cd ${S}/tools

	install -m 0755 boot_merger ${D}/${bindir}
	install -m 0755 trust_merger ${D}/${bindir}
	install -m 0755 firmwareMerger ${D}/${bindir}

	install -m 0755 kernelimage ${D}/${bindir}
	install -m 0755 loaderimage ${D}/${bindir}

	install -m 0755 mkkrnlimg ${D}/${bindir}
	install -m 0755 resource_tool ${D}/${bindir}

	install -m 0755 upgrade_tool ${D}/${bindir}

	cd ${S}/extra/linux/Linux_Pack_Firmware/rockdev

	install -m 0755 afptool ${D}/${bindir}
	install -m 0755 rkImageMaker ${D}/${bindir}
}


NATIVE_TOOLS = "boot_merger trust_merger firmwareMerger loaderimage mkkrnlimg resource_tool upgrade_tool"
NATIVE_EXTRA_TOOLS = "afptool rkImageMaker"

addtask deploy before do_build after do_compile
do_deploy () {
	cd ${S}/tools
	
	if [ ! -e ${DEPLOY_DIR_IMAGE}/rk_tools ]; then
		install -d ${DEPLOY_DIR_IMAGE}/rk_tools
	fi

	for binary in "${NATIVE_TOOLS}"; do
		if [[ ! -e ${DEPLOY_DIR_IMAGE}/rk_tools/${binary} ]]; then
			install -m 0755 ${binary}  ${DEPLOY_DIR_IMAGE}/rk_tools
		fi
	done

	cd ${S}/extra/linux/Linux_Pack_Firmware/rockdev

	for binary in "${NATIVE_EXTRA_TOOLS}"; do
		if [[ ! -e ${DEPLOY_DIR_IMAGE}/rk_tools/${binary} ]]; then
			install -m 0755 ${binary}  ${DEPLOY_DIR_IMAGE}/rk_tools
		fi
	done
}
