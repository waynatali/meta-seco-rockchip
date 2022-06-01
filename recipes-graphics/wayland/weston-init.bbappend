

FILESEXTRAPATHS:append := "${THISDIR}/files:"

SRC_URI += "file://seco-weston.ini"
 
do_install:append() {
    install -D -p -m0644 ${WORKDIR}/seco-weston.ini ${D}${sysconfdir}/xdg/weston/weston.ini
}
