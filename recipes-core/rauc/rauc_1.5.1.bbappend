SYSTEMD_SERVICE_${PN}-mark-good:remove:seco-px30-d23 = "rauc-mark-good.service"

do_install:append:seco-px30-d23 () {
	rm ${D}${systemd_unitdir}/system/rauc-mark-good.service
	rm ${D}${sysconfdir}/init.d/rauc-mark-good
}
