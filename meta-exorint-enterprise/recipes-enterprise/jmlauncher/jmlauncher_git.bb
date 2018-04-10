DESCRIPTION = "HMI desktop application"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

PR = "r22"
SRCNAME = "jml"

SRCBRANCH = "exorint-1.x.x"
SRCREV = "6669939a630535a2f693d7237bf10cc03eee2119"

inherit exorint-src
inherit qmake2

DEPENDS += "qt4-x11-free"

RDEPENDS_${PN} += "packagegroup-qt-x11-min"

# microsom configuration
EXTRA_QMAKEVARS_PRE += "CONFIG+=usom01"

# avoid automatic source generation
EXTRA_QMAKEVARS_PRE += "CONFIG+=no_dbusxml2cpp"

# avoid automatic stripping - Yocto will handle it
EXTRA_QMAKEVARS_PRE += "CONFIG+=debug"

FILES_${PN} += "${datadir}/dbus-1/"

do_install() {
    export INSTALL_ROOT=${D}
    oe_runmake install
}
