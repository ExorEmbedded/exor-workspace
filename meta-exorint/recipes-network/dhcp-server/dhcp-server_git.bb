DESCRIPTION = "DHCP Server Script (based on Busybox udhcpd)"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += "file://init"

S = "${WORKDIR}"

PR = "x1"

inherit update-rc.d

do_install() {

        mkdir -p ${D}/${sysconfdir}/init.d
        install -m 0755 init ${D}/${sysconfdir}/init.d/dhcp-server
}

INITSCRIPT_NAME = "${PN}"
INITSCRIPT_PARAMS = "defaults 86 16"
