DESCRIPTION = "Provides a splash screen with a disclaimer about current bsp version"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "file://LICENSE"
SRC_URI += "file://unstable.sh"

S = "${WORKDIR}"

PR = "r1"

inherit update-rc.d

INITSCRIPT_NAME = "unstable.sh"
INITSCRIPT_PARAMS = "start 21 S ."

do_install() {

	mkdir -p ${D}/${sysconfdir}/init.d
	install -m 0755 unstable.sh ${D}/${sysconfdir}/init.d

}
