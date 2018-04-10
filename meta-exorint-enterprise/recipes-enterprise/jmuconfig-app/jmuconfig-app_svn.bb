DESCRIPTION = "WebKit Browser"

LICENSE = "Proprietary"
FILESEXTRAPATHS += "${THISDIR}/files"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

PR = "r29"
SRCREV = "r64411"
S = "${WORKDIR}/hmibrowser"

#inherit exorint-src
inherit qmake2

SRC_URI = "svn://exorint.unfuddle.com/svn/exorint_qthmi/branches/Production;module=hmibrowser;protocol=https; \
	file://jmuconfig-app"

DEPENDS += "qt4-x11-free"

RDEPENDS_${PN} += "packagegroup-qt-x11-min"

do_install() {
    INSTALL_ROOT=${D} make install
    install -m 0755 ${WORKDIR}/jmuconfig-app ${D}${bindir}/jmuconfig-app
}
