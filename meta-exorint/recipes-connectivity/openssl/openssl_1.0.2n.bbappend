PR := "${PR}.x0"

do_install_append () {
    # the openssl config file is usually linked to /etc, but our /etc/ssl points
    # to the possibly empty /mnt/factory/etc/ssl; fix this by replacing the symlink in
    # ${libdir} with a file
    rm -f ${D}${libdir}/ssl/openssl.cnf
    cp ${sysconfdir}/ssl/openssl.cnf ${D}${libdir}/ssl/
}
