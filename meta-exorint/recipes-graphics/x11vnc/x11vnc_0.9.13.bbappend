FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PR := "${PR}.x1"

SRC_URI += "file://init \
	file://x11vnc.conf"

inherit update-rc.d
INITSCRIPT_NAME = "${PN}"
INITSCRIPT_PARAMS = "defaults 20"

do_install_append() {
	mkdir -p ${D}${sysconfdir}/init.d
	install -m 0755 ${WORKDIR}/init ${D}${sysconfdir}/init.d/${PN}

	mkdir -p ${D}${sysconfdir}/x11vnc
	install -m 0644 ${WORKDIR}/x11vnc.conf ${D}${sysconfdir}/x11vnc/
}

do_package_qa() {
	:
}
