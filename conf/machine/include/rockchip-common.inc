# Copyright (c) 2019, Fuzhou Rockchip Electronics Co., Ltd
# Released under the MIT license (see COPYING.MIT for the terms)

require conf/machine/include/soc-family.inc

MACHINE_EXTRA_RRECOMMENDS:append = " \
	${RK_WIFIBT_FIRMWARES} \
	kernel-modules \
"

SERIAL_CONSOLES ?= "115200;ttyFIQ0"
KERNEL_IMAGETYPE ?= "Image"
MACHINEOVERRIDES .= ":rockchip"

# Firmware
MACHINE_FIRMWARE ?= ""
MACHINE_EXTRA_RRECOMMENDS += "${MACHINE_FIRMWARE}"

PREFERRED_PROVIDER_virtual/bootloader = "u-boot-seco"
PREFERRED_VERSION_u-boot-toradex = "2017.09%"

PREFERRED_PROVIDER_virtual/kernel ?= "linux-seco"
PREFERRED_VERSION_linux-seco ?= "5.10%"
LINUXLIBCVERSION ?= "5.10%"

# Custom kernel might not support newest python
PACKAGECONFIG:remove:pn-perf = " scripting"

PREFERRED_PROVIDER_virtual/egl ?= "${@'rockchip-libmali' if d.getVar('TCLIBC') == 'glibc' else 'mesa'}"
PREFERRED_PROVIDER_virtual/libgles1 ?= "${@'rockchip-libmali' if d.getVar('TCLIBC') == 'glibc' else 'mesa'}"
PREFERRED_PROVIDER_virtual/libgles2 ?= "${@'rockchip-libmali' if d.getVar('TCLIBC') == 'glibc' else 'mesa'}"
PREFERRED_PROVIDER_virtual/libgles3 ?= "${@'rockchip-libmali' if d.getVar('TCLIBC') == 'glibc' else 'mesa'}"
PREFERRED_PROVIDER_virtual/libopencl ?= "${@'rockchip-libmali' if d.getVar('TCLIBC') == 'glibc' else 'mesa'}"
PREFERRED_PROVIDER_virtual/libgbm ?= "${@'rockchip-libmali' if d.getVar('TCLIBC') == 'glibc' else 'mesa'}"
PACKAGECONFIG:pn-wayland ?= "${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'no-egl', '', d)}"

DEPENDS:append:pn-mesa-gl = "${@'rockchip-libmali' if d.getVar('TCLIBC') == 'glibc' else ''}"

PREFERRED_PROVIDER_virtual/libgl ?= "${@'mesa-gl' if d.getVar('TCLIBC') == 'glibc' else 'mesa'}"
PREFERRED_PROVIDER_virtual/mesa ?= "${@'mesa-gl' if d.getVar('TCLIBC') == 'glibc' else 'mesa'}"

PREFERRED_RPROVIDER_lib32-initd-functions = "lib32-initscripts"

export RK_ROOTDEV_UUID ?= "614e0000-0000-4b53-8000-1d28000054a9"
export RK_PARTITION_GROW ?= "1"

RK_USE_COMPRESSED_KERNEL ?= "1"
RDEPENDS:${KERNEL_PACKAGE_NAME}-base = ""

RK_MINILOADER_INI ?= "${@d.getVar('SOC_FAMILY').upper() + 'MINIALL.ini'}"
RK_TRUST_INI ?= "${@d.getVar('SOC_FAMILY').upper() + 'TOS.ini'}"
RK_IGNORE_BL32 ?= "0"

# loader's size(K) and backup num
RK_LOADER_SIZE ?= "1024"
RK_LOADER_BACKUP_NUM ?= "4"

IMAGE_FSTYPES:remove = "iso live"
export RK_ROOTFS_TYPE ?= "ext4"

IMAGE_FSTYPES:append = " ${RK_ROOTFS_TYPE} wic"
WKS_FILE ?= "gptdisk.wks.in"

# Some partitons, e.g. trust, are allowed to be optional.
do_image_wic[depends] += " \
	virtual/kernel:do_deploy \
	virtual/bootloader:do_deploy \
"
IMAGE_BOOT_FILES ?= " \
	${KERNEL_IMAGETYPE} \
	${IMG_KERNEL_DEVICETREE} \
"

RK_POST_ROOTFS_SCRIPTS ?= ""
RK_OVERLAY_DIRS ?= ""
BB_BASEHASH_IGNORE_VARS:append = " RK_POST_ROOTFS_SCRIPTS RK_OVERLAY_DIRS"

# <fslabel:mountpoint> e.g. "oem:/oem userdata:/userdata"
RK_EXTRA_VOLUMES ?= ""

ROOTFS_POSTPROCESS_COMMAND:append = " do_post_rootfs;"
do_rootfs[depends] += "rsync-native:do_populate_sysroot"
do_post_rootfs() {
	for volume in ${RK_EXTRA_VOLUMES};do
		echo "Creating ${volume##*:} for ${volume%:*}(fslabel)..."
		mkdir -p "${IMAGE_ROOTFS}${volume##*:}"

		echo "PARTLABEL=${volume%:*}\t${volume##*:}\tauto defaults 0 2" \
			>> "${IMAGE_ROOTFS}/etc/fstab"
	done

	for overlay in ${RK_OVERLAY_DIRS};do
		[ -d "${overlay}" ] || continue
		echo "Installing overlay: ${overlay}..."
		rsync -av --chmod=u=rwX,go=rX "${overlay}/" "${IMAGE_ROOTFS}"
	done

	for script in ${RK_POST_ROOTFS_SCRIPTS};do
		[ -f "${script}" ] || continue
		echo "Running script: ${script}..."
		cd "${script%/*}"
		"${script}" "${IMAGE_ROOTFS}"
	done
}

IMAGE_POSTPROCESS_COMMAND:append = " link_rootfs_image;"
link_rootfs_image() {
	ln -sf "${IMAGE_LINK_NAME}.${RK_ROOTFS_TYPE}" \
		"${IMGDEPLOYDIR}/rootfs.img"
}

IMAGE_POSTPROCESS_COMMAND:append = " gen_rkparameter;"
gen_rkparameter() {
	IMAGE="${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.wic"
	if [ ! -f "${IMAGE}" ];then
		echo "${IMAGE} not found."
		return
	fi

	cd "${IMGDEPLOYDIR}"

	OUT="${IMAGE_LINK_NAME}.parameter"
	ln -sf "${OUT}" parameter

	echo "Generating ${OUT}..."

	echo "# IMAGE_NAME: $(readlink ${IMAGE})" > "${OUT}"
	echo "FIRMWARE_VER: 1.0" >> "${OUT}"
	echo "TYPE: GPT" >> "${OUT}"
	echo -n "CMDLINE: mtdparts=rk29xxnand:" >> "${OUT}"
	sgdisk -p "${IMAGE}" | grep -E "^ +[0-9]" | while read line;do
		NAME=$(echo ${line} | cut -f 7 -d ' ')
		START=$(echo ${line} | cut -f 2 -d ' ')
		END=$(echo ${line} | cut -f 3 -d ' ')
		SIZE=$(expr ${END} - ${START} + 1)
		printf "0x%08x@0x%08x(%s)," ${SIZE} ${START} ${NAME} >> "${OUT}"
	done
	echo >> "${OUT}"

	if [ "$RK_PARTITION_GROW" = "1" ];then
		sed -i "s/[^,]*\(@[^,]*\)),$/-\1:grow)/" "${OUT}"
	fi

	echo "uuid: rootfs=${RK_ROOTDEV_UUID}" >> "${OUT}"
}

IMAGE_POSTPROCESS_COMMAND:append = " link_latest_image;"
link_latest_image() {
	rm -rf "${TOPDIR}/latest"
	ln -sf "${DEPLOY_DIR_IMAGE}" "${TOPDIR}/latest"
}
