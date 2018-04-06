DESCRIPTION = "Provides a checks for good start of touchscreen"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

FILESEXTRAPATHS := "${THISDIR}/files"

SRC_URI = "file://LICENSE"
SRC_URI += "file://checks.sh"

S = "${WORKDIR}"

PR = "r1"

inherit update-rc.d

INITSCRIPT_NAME = "checks.sh"
INITSCRIPT_PARAMS = "start 70 S ."

do_install() {
	mkdir -p ${D}/${sysconfdir}/init.d
	install -m 0755 checks.sh ${D}/${sysconfdir}/init.d
}
