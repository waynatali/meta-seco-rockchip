inherit ${@'auto-patch' if "seco-px30-d23" in d.getVar('MACHINEOVERRIDES').split(":") else ''}
PATCHPATH:seco-px30-d23 = "${CURDIR}/u-boot"

FILESEXTRAPATHS:prepend:seco-px30-d23 := "${THISDIR}/files:"

# When updating this revision, be careful, as not all binaries are suitable.
# tested binary is px30_loader_v1.11.115.bin. (combination of FlashData=bin/rk33/px30_ddr_333MHz_v1.11.bin and FlashBoot=bin/rk33/px30_miniloader_v1.15.bin)
# see file PX30MINIALL.ini
SRCREV_rkbin = "fd4e26d31c5f8f34709ccae7b58afa05824de0cd"
SRC_URI:append:seco-px30-d23 = " \
	git://github.com/JeffyCN/mirrors.git;protocol=https;branch=rkbin;name=rkbin;destsuffix=rkbin; \
	file://flash_d23.sh \
	file://uEnvD23.txt \
	file://boot.cmd \
"

SRCREV_FORMAT = "default_rkbin"

DEPENDS:append:seco-px30-d23 = " rkdeveloptool-native"

LICENSE:append:seco-px30-d23 = " & LICENSE.rockchip"
LIC_FILES_CHKSUM:append:seco-px30-d23 = " file://${RKBASE}/licenses/LICENSE.rockchip;md5=d63890e209bf038f44e708bbb13e4ed9"

RK_IDBLOCK_IMG = "idblock.img"
RK_LOADER_BIN = "loader.bin"
RK_TRUST_IMG = "trust.img"
UBOOT_BINARY = "uboot.img"

do_compile:append:seco-px30-d23() {
	cd ${B}
	# Pack uboot image
	${WORKDIR}/rkbin/tools/loaderimage --pack --uboot u-boot.bin ${UBOOT_BINARY} 0x00200000
	
	# Pack trust image	
	cd ${WORKDIR}/rkbin
	${WORKDIR}/rkbin/tools/trust_merger --rsa 3 --ignore-bl32  ${WORKDIR}/rkbin/RKTRUST/PX30TRUST.ini
	mv ${WORKDIR}/rkbin/trust*.img ${B}
	
	# Pack loader image
	${WORKDIR}/rkbin/tools/boot_merger  ${WORKDIR}/rkbin/RKBOOT/PX30MINIALL.ini
	echo "pack loader okay! Input: ${WORKDIR}/rkbin/RKBOOT/PX30MINIALL.ini"

	cd - && mv ${WORKDIR}/rkbin/*_loader_*.bin ./		
	ln -sf *_loader*.bin "${RK_LOADER_BIN}"

	# Generate idblock image
	bbnote "${PN}: Generating ${RK_IDBLOCK_IMG} from ${RK_LOADER_BIN}"
	${WORKDIR}/rkbin/tools/boot_merger --unpack "${RK_LOADER_BIN}"

	if [ -f FlashHead ];then
		cat FlashHead FlashData > "${RK_IDBLOCK_IMG}"
	else
		./tools/mkimage -n "${SOC_FAMILY}" -T rksd -d FlashData "${RK_IDBLOCK_IMG}"
	fi

	cat FlashBoot >> "${RK_IDBLOCK_IMG}"
}

do_deploy:append:seco-px30-d23() {
	cd ${B}

	for binary in "${RK_IDBLOCK_IMG}" "${RK_LOADER_BIN}" "${RK_TRUST_IMG}" "${UBOOT_BINARY}";do
		[ -f "${binary}" ] || continue
		install "${binary}" "${DEPLOYDIR}/${binary}-${PV}"
		ln -sf "${binary}-${PV}" "${DEPLOYDIR}/${binary}"
	done
	
	cd ${DEPLOY_DIR_IMAGE}
	for file_deployed in seco_boot.scr uEnvD23.txt flash_d23.sh upgrade_tool *_loader*.bin;do
		ls ${file_deployed} >/dev/null 2>&1 && rm ${file_deployed}	
	done

	cd -
	cp ${WORKDIR}/boot.cmd ${B}
	sed -i -e '/root_dev/ s/rootwait/rootwait rootfstype=${ROOT_FSTYPE}/g' boot.cmd
	./tools/mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "Boot Script" -d boot.cmd seco_boot.scr
	install -m 0755 *_loader*.bin ${DEPLOYDIR}
	install -m 0755 ${WORKDIR}/rkbin/tools/upgrade_tool ${DEPLOYDIR}
	install -m 0755 ${WORKDIR}/flash_d23.sh ${DEPLOYDIR}
	install -m 0755 ${WORKDIR}/uEnvD23.txt ${DEPLOYDIR}
	install -m 0755 seco_boot.scr ${DEPLOYDIR}
	sed -i -e '/^bootargs/ s/$/ rootfstype=${ROOT_FSTYPE}/g' ${DEPLOYDIR}/uEnvD23.txt
}
