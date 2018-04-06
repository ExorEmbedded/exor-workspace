PR := "${PR}.x3"

FILESEXTRAPATHS := "${THISDIR}/${PN}-${PV}"

SRC_URI_append = " \
    file://xorg-xserver-common \
"

do_install_append () {

    # Remove config files which have migrated to base
    rm ${D}${sysconfdir}/X11/Xsession.d/90xXWindowManager.sh
    rm ${D}${sysconfdir}/X11/Xinit.d/55xScreenSaver

    # Substitute xserver-common
    install -m 755 ${WORKDIR}/xorg-xserver-common ${D}${sysconfdir}/X11/xserver-common
}

PACKAGE_ARCH = "${MACHINE_ARCH}"
