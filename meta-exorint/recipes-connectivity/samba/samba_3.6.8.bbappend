# Add winbind host resolution to nsswitch.conf

PR = "r9"

pkg_postinst_libwinbind () {
        sed -e 's/\(^hosts:.*\)/\1 wins/' -i $D${sysconfdir}/nsswitch.conf
}

pkg_prerm_libwinbind () {
        sed -e '/^hosts:/s/wins\s*//' -i $D${sysconfdir}/nsswitch.conf
}

FILES_libwinbind += " ${libdir}/libnss_*${SOLIBS}"

PACKAGE_EXCLUDE = "winbind"
