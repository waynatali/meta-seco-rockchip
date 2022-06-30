# Copyright (C) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the MIT license (see COPYING.MIT for the terms)

require u-boot-seco-common.inc
require recipes-bsp/u-boot/u-boot.inc

inherit auto-patch

PATCHPATH = "${CURDIR}/u-boot"

inherit python3-dir

FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot:"

inherit freeze-rev

# When updating this revision, be careful, as not all binaries are suitable.
# tested binary is px30_loader_v1.11.115.bin. (combination of FlashData=bin/rk33/px30_ddr_333MHz_v1.11.bin and FlashBoot=bin/rk33/px30_miniloader_v1.15.bin)
# see file PX30MINIALL.ini
SRCREV_rkbin = "fd4e26d31c5f8f34709ccae7b58afa05824de0cd"
SRC_URI += " \
	git://github.com/JeffyCN/mirrors.git;protocol=https;branch=rkbin;name=rkbin;destsuffix=rkbin; \
	file://flash_d23.sh \
	file://uEnvD23.txt \
	file://boot.cmd \
"
SRC_URI:remove = "file://0001-riscv32-Use-double-float-ABI-for-rv32.patch"
SRC_URI:remove = "file://0001-riscv-fix-build-with-binutils-2.38.patch"

SRCREV_FORMAT = "default_rkbin"

DEPENDS:append = " ${PYTHON_PN}-native"

# Needed for packing BSP u-boot
DEPENDS:append = " coreutils-native ${PYTHON_PN}-pyelftools-native"

do_configure:prepend() {
	# Make sure we use /usr/bin/env ${PYTHON_PN} for scripts
	for s in `grep -rIl python ${S}`; do
		sed -i -e '1s|^#!.*python[23]*|#!/usr/bin/env ${PYTHON_PN}|' $s
	done

	# Support python3
	sed -i -e 's/\(open(.*[^"]\))/\1, "rb")/' -e 's/,$//' \
		-e 's/print >> \([^,]*\), *\(.*\)$/print(\2, file=\1)/' \
		-e 's/print \(.*\)$/print(\1)/' \
		${S}/arch/arm/mach-rockchip/make_fit_atf.py

	# Remove unneeded stages from make.sh
	sed -i -e 's/^select_toolchain$//g' -e '/^clean/d' -e '/^\t*make/d' ${S}/make.sh

	if [ "x${RK_ALLOW_PREBUILT_UBOOT}" = "x1" ]; then
		# Copy prebuilt images
		if [ -e "${S}/${UBOOT_BINARY}" ]; then
			bbnote "${PN}: Found prebuilt images."
			mkdir -p ${B}/prebuilt/
			mv ${S}/*.bin ${S}/*.img ${B}/prebuilt/
		fi
	fi

	[ -e "${S}/.config" ] && make -C ${S} mrproper
}

# Generate Rockchip style loader binaries
RK_IDBLOCK_IMG = "idblock.img"
RK_LOADER_BIN = "loader.bin"
RK_TRUST_IMG = "trust.img"
UBOOT_BINARY = "uboot.img"

do_compile:append() {
	cd ${B}

	if [ -e "${B}/prebuilt/${UBOOT_BINARY}" ]; then
		bbnote "${PN}: Using prebuilt images."
		ln -sf ${B}/prebuilt/*.bin ${B}/prebuilt/*.img ${B}/
	else
		# Prepare needed files
		for d in make.sh scripts configs arch/arm/mach-rockchip; do
			cp -rT ${S}/${d} ${d}
		done

		# Pack rockchip loader images
		./make.sh
	fi

	ln -sf *_loader*.bin "${RK_LOADER_BIN}"

	# Generate idblock image
	bbnote "${PN}: Generating ${RK_IDBLOCK_IMG} from ${RK_LOADER_BIN}"
	./tools/boot_merger --unpack "${RK_LOADER_BIN}"

	if [ -f FlashHead ];then
		cat FlashHead FlashData > "${RK_IDBLOCK_IMG}"
	else
		./tools/mkimage -n "${SOC_FAMILY}" -T rksd -d FlashData \
			"${RK_IDBLOCK_IMG}"
	fi

	cat FlashBoot >> "${RK_IDBLOCK_IMG}"
}

do_deploy:append() {
	cd ${B}

	for binary in "${RK_IDBLOCK_IMG}" "${RK_LOADER_BIN}" "${RK_TRUST_IMG}";do
		[ -f "${binary}" ] || continue
		install "${binary}" "${DEPLOYDIR}/${binary}-${PV}"
		ln -sf "${binary}-${PV}" "${DEPLOYDIR}/${binary}"
	done
	cp ../boot.cmd ${B}
	sed -i -e '/root_dev/ s/rootwait/rootwait rootfstype=${ROOT_FSTYPE}/g' boot.cmd
	./tools/mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "Boot Script" -d boot.cmd seco_boot.scr
	install -m 0755 *_loader*.bin ${DEPLOYDIR}
	install -m 0755 ${WORKDIR}/rkbin/tools/upgrade_tool ${DEPLOYDIR}
	install -m 0755 ${WORKDIR}/flash_d23.sh ${DEPLOYDIR}
	install -m 0755 ${WORKDIR}/uEnvD23.txt ${DEPLOYDIR}
	install -m 0755 seco_boot.scr ${DEPLOYDIR}
	sed -i -e '/^bootargs/ s/$/ rootfstype=${ROOT_FSTYPE}/g' ${DEPLOYDIR}/uEnvD23.txt
}
