DESCRIPTION = "Creates LTE Modem application"
HOMEPAGE = "https://www.seco.com"
PR = "r1"
LICENSE = "CLOSED"

inherit systemd
RDEPENDS_${PN} += "bash"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:" 

S = "${WORKDIR}"

INSANE_SKIP:${PN} = "already-stripped"

SRC_URI = "file://quectel-CM.tar.gz"

do_install() {
    install -d ${D}${base_bindir}
    install -m 0755 ${WORKDIR}/quectel-CM/quectel-CM   ${D}${base_bindir}
}
