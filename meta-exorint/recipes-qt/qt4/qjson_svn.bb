SUMMARY = "Qt4 Backport of QJson"
DESCRIPTION = "This is a backport of QJson from Qt5.2.1 to Qt4.8. It is based on the initial backport from https://github.com/5in4/qjson-backport"
HOMEPAGE = "https://github.com/jdevera/qjson-backport"

LICENSE = "LGPL-2.1"
LIC_FILES_CHKSUM = "file://README.license;md5=e4fcd0d2d9063745f559ea4809e0484c"

PR = "r2"
SRCREV = "r89"

SRC_URI = "svn://exorint.unfuddle.com/svn/exorint_unupdwce600/branches/linux/RemoteHMIConfigurator;module=QJson;protocol=https"
S = "${WORKDIR}/QJson"

inherit qmake2

DEPENDS += "qt4-x11-free"

do_compile() {

    # compile avoiding host dirs being linked (clash with Qt variable)
    libdir="" make
}

do_install() {

    INSTALL_ROOT=${D} make install

}
