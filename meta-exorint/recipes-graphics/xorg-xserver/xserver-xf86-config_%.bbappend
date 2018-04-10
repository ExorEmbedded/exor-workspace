FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append_usom03 = " file://vivante.conf"

do_install_append_usom03() {
	install -d ${D}/${sysconfdir}/X11/xorg.conf.d
	install -m 0644 ${WORKDIR}/vivante.conf ${D}/${sysconfdir}/X11/xorg.conf.d/	
}
