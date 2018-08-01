FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://disable-configuration-rescan.patch"

do_install_append() {
	# Disable font hinting causing font rendering issues in qt4
	rm ${D}/${sysconfdir}/fonts/conf.d/10-hinting-slight.conf
}
