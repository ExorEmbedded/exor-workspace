PR := "${PR}.x0"

do_install_append () {

    # Remove config files which have migrated to base
    rm ${D}${sysconfdir}/X11/Xsession

}
