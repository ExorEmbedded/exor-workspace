DESCRIPTION = "DBUS daemon with support functions for Exor specific linux hardware and BSP"

LICENSE = "Proprietary"
LIC_FILES_CHKSUM = "file://LICENSE;md5=a26136a158a7bd489efe50329e38188a"

PR = "r150"
SRCNAME = "ltools-${BPN}"

SRCBRANCH = "rocko-1.x.x"
SRCREV = "dc6c88ac276237ac363c706de94e4164f0235c9e"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-files:"

SRCBRANCH_ca16 = "pgd_ca-1.x.x"
SRCREV_ca16 = "17c5f7b3a03a9fbb9d8cf543786a37109c721917"

inherit exorint-src

SRC_URI += "file://if-up"
SRC_URI += "file://if-down"
SRC_URI += "file://ppp-up"
SRC_URI += "file://ppp-down"
SRC_URI += "file://vpn-up"
SRC_URI += "file://vpn-down"

inherit qmake2 gtk-immodules-cache

PACKAGES += "${PN}-im"
PROVIDES += "${PN}-im"

DEPENDS += "qt4-x11-free gtk+ libxtst"

RDEPENDS_${PN} += "packagegroup-qt-x11-min ${PN}-im"

# microsom configuration
EXTRA_QMAKEVARS_PRE += "CONFIG+=usom01"

# avoid automatic source generation
EXTRA_QMAKEVARS_PRE += "CONFIG+=no_dbusxml2cpp"

# avoid automatic stripping - Yocto will handle it
EXTRA_QMAKEVARS_PRE += "CONFIG+=debug"

# avoid libEPAD.so ending up in -dev package
FILES_${PN}-dev = ""
FILES_${PN} += "${libdir}/libEPAD.so"
FILES_${PN} += "${datadir}/dbus-1/"

FILES_${PN}-im = "${libdir}/gtk-2.0/2.10.0/immodules/ \
	${libdir}/gtk-2.0/2.10.0/immodules/*.so"

FILES_${PN}-dbg += "${libdir}/gtk-2.0/2.10.0/immodules/.debug/*"

do_install() {
    export INSTALL_ROOT=${D}
    oe_runmake install
    if [ -e "${S}/build-usom01-debug/libMODH.so" ]; then
        install -m 755 ${S}/build-usom01-debug/libMODH.so ${D}/usr/bin
    fi

	mkdir -p ${D}${sysconfdir}/network/if-up.d
	install -m 0755 ${WORKDIR}/if-up ${D}${sysconfdir}/network/if-up.d/01-epad-notify
	mkdir -p ${D}${sysconfdir}/network/if-down.d
	install -m 0755 ${WORKDIR}/if-down ${D}${sysconfdir}/network/if-down.d/01-epad-notify

	mkdir -p ${D}${sysconfdir}/ppp/ip-up.d
	install -m 0755 ${WORKDIR}/ppp-up ${D}${sysconfdir}/ppp/ip-up.d/01-epad-notify
	mkdir -p ${D}${sysconfdir}/ppp/ip-down.d
	install -m 0755 ${WORKDIR}/ppp-down ${D}${sysconfdir}/ppp/ip-down.d/01-epad-notify

	mkdir -p ${D}${sysconfdir}/openvpn/ifup.client.d
	install -m 0755 ${WORKDIR}/vpn-up ${D}${sysconfdir}/openvpn/ifup.client.d/01-epad-notify
	mkdir -p ${D}${sysconfdir}/openvpn/ifdown.client.d
	install -m 0755 ${WORKDIR}/vpn-down ${D}${sysconfdir}/openvpn/ifdown.client.d/01-epad-notify
}

GTKIMMODULES_PACKAGES = "${PN}-im"

PACKAGE_ARCH = "${MACHINE_ARCH}"
