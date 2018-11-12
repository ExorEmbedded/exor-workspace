DESCRIPTION = "Cloud Enabler Service"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=4144008b4d33581741e1e9db045c9be4"

PR = "x10"
SRCREV = "dd56bc1d74564cab0e03a009ee4a27f16b85eb68"
SRCBRANCH = "exorint-1.x.x"
SRC_URI = "git://github.com/ExorEmbedded/encloud.git;branch=${SRCBRANCH}"

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
