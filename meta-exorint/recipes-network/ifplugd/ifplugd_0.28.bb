DESCRIPTION = "Daemon for monitoring ethernet device link state"

SECTION = "Networking/Daemons"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM ="file://LICENSE;md5=94d55d512a9ba36caa9b7df079bae19f"

PR := "${PR}.x12"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:${THISDIR}/files:"

# SRC_URI += "http://0pointer.de/lennart/projects/${PN}/${PN}-${PV}.tar.gz"
SRC_URI = "ftp://ftp.uwsg.indiana.edu/linux/gentoo/distfiles/${PN}-${PV}.tar.gz"
SRC_URI += "file://conf-control-all-interfaces.patch"
SRC_URI += "file://conf-delay-down-3s.patch"
SRC_URI += "file://init"
SRC_URI += "file://ifplugd.action"

SRC_URI[md5sum] = "df6f4bab52f46ffd6eb1f5912d4ccee3"
SRC_URI[sha256sum] = "474754ac4ab32d738cbf2a4a3e87ee0a2c71b9048a38bdcd7df1e4f9fd6541f0"

INITSCRIPT_NAME = "${PN}"
# Note: must start after networking because it depends on '/etc/network/interfaces' generation [#779]
INITSCRIPT_PARAMS = '${@base_contains("MACHINE_FEATURES", "fastboot", "defaults 5 96", "defaults 17 96",d)}'
INITSCRIPT_PARAMS_wu16 = "defaults 40 96"

inherit autotools update-rc.d

do_install_append() {
	install -m 0644 -d ${D}${sysconfdir}/network.persist/
	install -m 0755 ${WORKDIR}/init ${D}${sysconfdir}/init.d/ifplugd
	install -m 0755 ${WORKDIR}/ifplugd.action ${D}${sysconfdir}/ifplugd/ifplugd.action
}

do_install_append_us03-be15() {
    #903 Renegotiate eth1 for fix problem.
    touch ${D}${sysconfdir}/network.persist/eth1.renegotiate
}
do_install_append_us03-be15c() {
    #903 Renegotiate eth1 for fix problem.
    touch ${D}${sysconfdir}/network.persist/eth1.renegotiate
}

# Disable buzzer on ifup/ifdown
do_install_append_carel () {
   sed -i'' 's:^\(ARGS=.*\)":\1 -b":' ${D}${sysconfdir}/ifplugd/ifplugd.conf
}

DEPENDS += "libdaemon"

RDEPENDS_${PN} += "libdaemon"

PACKAGES += "extras"

EXTRA_OECONF_append = " --disable-lynx"
