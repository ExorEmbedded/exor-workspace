FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://chpass_hash.sh"

do_install_prepend() {
	install -d ${D}${bindir}/
	install -m 744 ${WORKDIR}/chpass_hash.sh ${D}${bindir}/
}

FILES_${PN} += "${bindir}/chpass_hash.sh"
