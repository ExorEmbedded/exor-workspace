DESCRIPTION = "Add custon TiWL18xx conf file"

SRC_URI_append = " \
	file://wl18xx-conf.tar.gz \
"

S = "${WORKDIR}/git"

CLEANBROKEN = "1"

do_install_append() {
    #installed custom file
    cp ${WORKDIR}/wl18xx-conf.bin ${D}${base_libdir}/firmware/ti-connectivity/
}

FILES_${PN} = "/lib/firmware/ti-connectivity/*"
