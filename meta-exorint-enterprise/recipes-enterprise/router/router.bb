DESCRIPTION = "Router Service"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

FILESEXTRAPATHS := "${THISDIR}/files"

SRC_URI = "file://LICENSE"
SRC_URI += "file://init"

S = "${WORKDIR}"

PR = "x14"

# No DNS/DHCP server implemented (yet)
#RDEPENDS_${PN} += "dnsmasq"

do_install() {

	mkdir -p ${D}/${sysconfdir}/init.d
	install -m 0755 init ${D}/${sysconfdir}/init.d/router

}
