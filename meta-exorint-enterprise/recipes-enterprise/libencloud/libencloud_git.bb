DESCRIPTION = "Cloud Enabler library"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=dc68c1fcebd31509ab35c671efe98470"

PR = "x17"
SCRBANCH = "exorint-1.x.x"
SRCREV = "f4ca902dafeac18df4e1349cf70232b6ba40790b"
SRC_URI = "git://github.com/ExorEmbedded/libencloud.git;branch=${SRCBRANCH}"

inherit exorint-src
inherit qmake2

DEPENDS += "qt4-x11-free"
DEPENDS += "qjson"

RDEPENDS_${PN} += "openvpn"
RDEPENDS_${PN} += "libqtcore4"
RDEPENDS_${PN} += "libqtnetwork4"
RDEPENDS_${PN} += "qjson"

# qmake environment
EXTRA_QMAKEVARS_PRE += "CONFIG+=exor"
EXTRA_QMAKEVARS_PRE += "CONFIG+=splitdeps"
# until simultaneous user/pass + X509 is permitted by Cloud Server, we use qcc
# mode (Connect API) also on devices instead of the ECE API
#EXTRA_QMAKEVARS_PRE += "CONFIG+=modeece"
EXTRA_QMAKEVARS_PRE += "CONFIG+=modeqcc"
EXTRA_QMAKEVARS_PRE += "CONFIG+=nogui"
EXTRA_QMAKEVARS_PRE += "CONFIG+=notest"

do_compile() {

    # compile avoiding host dirs being linked (clash with Qt variable)
    libdir="" make

}

do_install() {

    INSTALL_ROOT=${D} make install

}

FILES_${PN} += "${sysconfdir}/encloud/*"
