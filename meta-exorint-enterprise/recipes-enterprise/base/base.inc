DESCRIPTION = "Exor International Appliance Base Configuration"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PR = "r131"
SRCNAME = "yocto-base"
SRCBRANCH = "exorint-1.x.x"
SRCREV = "8767a8ba448219f07f3173fc6230a3fbadb0f33f"
SRC_URI = "git://github.com/ExorEmbedded/yocto-base.git;branch=${SRCBRANCH}"

inherit autotools
inherit exorint-src

SRC_URI += "file://ca16-JMTerminalEmulator"

RDEPENDS_${PN} += "formfactor"
RDEPENDS_${PN} += "sysvinit"
RDEPENDS_${PN} += "udev"
RDEPENDS_${PN} += "xserver-common"
RDEPENDS_${PN} += "initscripts"

RREPLACES_${PN} += "sysvinit-inittab"

PACKAGE_ARCH = "${MACHINE_ARCH}"

do_install_append_ca16 () {
    mkdir -p ${D}${sysconfdir}/X11/Xsession.d/
    install -m 0755 ${WORKDIR}/ca16-JMTerminalEmulator ${D}${sysconfdir}/X11/Xsession.d/78JMTerminalEmulator
}
