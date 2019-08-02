require base.inc

export CONFIG = "mainos"

RCONFLICTS_${PN} = "base-configos"

SRC_URI_append_us01-wu16 += "file://0001-wu16-rcS-superfast.patch \
                             file://0002-wu16-custom-X11-sessionfile.patch"

do_install_append_us01-wu16 () {
    chmod 0755 ${D}${sysconfdir}/X11/Xsession_post
}
