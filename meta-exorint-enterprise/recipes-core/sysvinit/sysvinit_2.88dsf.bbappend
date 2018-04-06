PR := "${PR}.x1"

FB = '${@base_contains("MACHINE_FEATURES", "fastboot", "1", "0",d)}'

do_install_append () {

    # Remove config files which have migrated to base
    rm ${D}${sysconfdir}/init.d/rc
    rm ${D}${sysconfdir}/init.d/rcS
    rm ${D}${sysconfdir}/default/rcS

    if [ ${FB} != 0 ]; then
	update-rc.d -r ${D} -f bootlogd remove
	update-rc.d -r ${D} bootlogd start 50 5 .
    fi

}
