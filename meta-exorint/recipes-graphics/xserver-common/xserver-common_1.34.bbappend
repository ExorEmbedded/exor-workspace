PR := "${PR}.x3"

do_install_append () {

    # Remove config files which have migrated to base
    rm ${D}${sysconfdir}/X11/Xinit.d/55xScreenSaver

    # Substitute xserver-common
    install -m 755 ${WORKDIR}/xorg-xserver-common ${D}${sysconfdir}/X11/xserver-common
}
