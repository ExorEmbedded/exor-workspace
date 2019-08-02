DESCRIPTION = "Provides a checks for good start of touchscreen"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "file://LICENSE"
SRC_URI_append_hsxx = " file://checks_hsxx.sh"
SRC_URI_append_jsxx = " file://checks_jsxx.sh"

S = "${WORKDIR}"

PR = "r2"

inherit update-rc.d

INITSCRIPT_NAME = "checks.sh"
INITSCRIPT_PARAMS = "start 70 S ."

RDEPENDS_${PN} += "bash"

do_install_append_hsxx() {
    mkdir -p ${D}/${sysconfdir}/init.d
    install -m 0755 checks_hsxx.sh ${D}/${sysconfdir}/init.d/checks.sh
}

do_install_append_jsxx() {
    mkdir -p ${D}/${sysconfdir}/init.d
    install -m 0755 checks_jsxx.sh ${D}/${sysconfdir}/init.d/checks.sh
}
