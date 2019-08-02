DESCRIPTION = "Router Service"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI = "file://LICENSE"
SRC_URI += "file://init"

S = "${WORKDIR}"

PR = "x22"

# No DNS/DHCP server implemented (yet)
#RDEPENDS_${PN} += "dnsmasq"

do_install() {

	mkdir -p ${D}/${sysconfdir}/init.d
	install -m 0755 init ${D}/${sysconfdir}/init.d/router

}

RDEPENDS_${PN} = "bash"

# INIT Note: this service is disabled by default and activated only for routers
# at runtime based on hw code (see /etc/init.d/rcS -> exorint_service_enable "router")
