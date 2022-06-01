DESCRIPTION = "U-Boot suppporting SECO boards based on Rockchip application processors"

PV = "2017.09+git${SRCPV}"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://Licenses/README;md5=a2c678cfd4a4d97135585cad908541c6"

DEPENDS:append = " rk-binary-native coreutils-native flex-native bison-native dtc-native"

UBOOT_SRC ?= "git://git.seco.com/pub/rockchip/u-boot-seco-rk2017.09.git;"
PROTOCOL ?= "protocol=ssh;"
SRCBRANCH = "develop"
SRCREV = "a0e34c8b7a41b1121b0a4275fd020a69419cbe12"

SRC_URI = "${UBOOT_SRC}branch=${SRCBRANCH};${PROTOCOL}"

S = "${WORKDIR}/git"
B = "${WORKDIR}/build"

do_configure[cleandirs] = "${B}"
PE = "1"
