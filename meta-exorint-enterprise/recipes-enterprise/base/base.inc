DESCRIPTION = "Exor International Appliance Base Configuration"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PR = "r132"
SRCNAME = "yocto-base"
SRCBRANCH = "rocko-1.x.x"
SRCREV = "d22f48d26bc122f158ae1359a20c0144c256cb98"

inherit autotools
inherit exorint-src

SRC_URI += "file://ca16-JMTerminalEmulator"

B = "${S}"
CLEANBROKEN = "1"

DEPENDS += "rsync-native"

RDEPENDS_${PN} += "bash"
RDEPENDS_${PN} += "formfactor"
RDEPENDS_${PN} += "sysvinit"
RDEPENDS_${PN} += "udev"
RDEPENDS_${PN} += "xserver-nodm-init"
RDEPENDS_${PN} += "initscripts"

RREPLACES_${PN} += "sysvinit-inittab"

PACKAGE_ARCH = "${MACHINE_ARCH}"

do_install_append() {
    chown -R root:root ${D}
}

do_install_append_ca16 () {
    mkdir -p ${D}${sysconfdir}/X11/Xsession.d/
    install -m 0755 ${WORKDIR}/ca16-JMTerminalEmulator ${D}${sysconfdir}/X11/Xsession.d/78JMTerminalEmulator
    chown -R root:root ${D}
}
