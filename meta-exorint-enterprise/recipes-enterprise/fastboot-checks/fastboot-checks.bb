DESCRIPTION = "Provides a checks for good start "

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

FILESEXTRAPATHS := "${THISDIR}/files"

SRC_URI = "file://LICENSE"
SRC_URI += "file://fastboot-prechecks.sh file://fastboot-postchecks.sh file://rcS_fastboot file://x11-input.conf"

S = "${WORKDIR}"

PR = "r12"

inherit update-rc.d

PACKAGES =+ "${PN}-prechecks ${PN}-postchecks ${PN}-fastbootwu16 ${PN}-fastbootx11"
FILES_${PN}-prechecks     = "${sysconfdir}/init.d/fastboot-prechecks.sh"
FILES_${PN}-postchecks    = "${sysconfdir}/init.d/fastboot-postchecks.sh"
FILES_${PN}-fastbootwu16  = "${sysconfdir}/init.d/rcS_fastboot"
FILES_${PN}-fastbootx11   = "${sysconfdir}/X11/xorg.conf.d/x11-input.conf"
DESCRIPTION_${PN}-prechecks  = "Fastboot prechecks"
DESCRIPTION_${PN}-postchecks = "Fastboot postchecks"
DESCRIPTION_${PN}-fastbootwu16 = "Fastboot super"
DESCRIPTION_${PN}-fastbootx11 = "Fastboot x11"

INITSCRIPT_PACKAGES = "${PN}-prechecks ${PN}-postchecks"
INITSCRIPT_NAME_${PN}-prechecks = "fastboot-prechecks.sh"
INITSCRIPT_NAME_${PN}-postchecks = "fastboot-postchecks.sh"
INITSCRIPT_PARAMS_${PN}-prechecks = "start 50 S ."
INITSCRIPT_PARAMS_${PN}-postchecks = "start 12 5 ."


do_install() {
	mkdir -p ${D}/${sysconfdir}/init.d
	install -m 0755 fastboot-prechecks.sh ${D}/${sysconfdir}/init.d
	install -m 0755 fastboot-postchecks.sh ${D}/${sysconfdir}/init.d
	install -m 0755 rcS_fastboot ${D}/${sysconfdir}/init.d
	mkdir -p ${D}/${sysconfdir}/X11/xorg.conf.d/
	install -m 0644 x11-input.conf ${D}/${sysconfdir}/X11/xorg.conf.d/x11-input.conf
}

