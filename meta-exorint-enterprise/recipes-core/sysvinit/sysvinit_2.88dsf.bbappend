PR := "${PR}.x1"

FB = '${@bb.utils.contains("MACHINE_FEATURES", "fastboot", "1", "0",d)}'

do_install_append () {

    # Remove config files which have migrated to base
    rm ${D}${sysconfdir}/init.d/rc
    rm ${D}${sysconfdir}/init.d/rcS
    rm ${D}${sysconfdir}/default/rcS

    update-rc.d -r ${D} -f bootlogd remove
    update-rc.d -r ${D} -f stop-bootlogd remove
    rm ${D}${sysconfdir}/init.d/bootlogd
    rm ${D}${sysconfdir}/init.d/stop-bootlogd
    rm ${D}${sysconfdir}/default/volatiles/01_bootlogd
}
