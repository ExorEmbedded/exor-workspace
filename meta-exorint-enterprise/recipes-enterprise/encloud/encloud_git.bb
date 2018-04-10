DESCRIPTION = "Cloud Enabler Service"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=dc68c1fcebd31509ab35c671efe98470"

PR = "x7"
SRCREV = "593b464a9ecb7de0596ee061bd5f84398ab6bc5c"
SRCBRANCH = "exorint-1.x.x"

inherit exorint-src

SRC_URI += "file://init"

inherit qmake2

DEPENDS += "qt4-x11-free"
DEPENDS += "libencloud"

RDEPENDS_${PN} += "libencloud"
RDEPENDS_${PN} += "bash"

# qmake environment
EXTRA_QMAKEVARS_PRE += "CONFIG+=exor"
EXTRA_QMAKEVARS_PRE += "CONFIG+=splitdeps"
# until simultaneous user/pass + X509 is permitted by Cloud Server, we use qcc
# mode (Connect API) also on devices instead of the ECE API
#EXTRA_QMAKEVARS_PRE += "CONFIG+=modeece"
EXTRA_QMAKEVARS_PRE += "CONFIG+=modeqcc"
EXTRA_QMAKEVARS_PRE += "CONFIG+=noservice"

do_compile() {

    # compile avoiding host dirs being linked (clash with Qt variable)
    libdir="" make

}

do_install() {

    INSTALL_ROOT=${D} make install
    sed -i'' "s:\(echo \"Starting.*\):\1\n\n    /sbin/modprobe tun:" ${D}/etc/init.d/encloud

	mv ${D}${sysconfdir}/init.d/encloud ${D}${sysconfdir}/init.d/encloud-real
	install -m 0755 ${WORKDIR}/init ${D}${sysconfdir}/init.d/encloud
}
