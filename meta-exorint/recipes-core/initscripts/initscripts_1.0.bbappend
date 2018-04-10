FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"

PR := "${PR}.x1"

FB = '${@bb.utils.contains("MACHINE_FEATURES", "fastboot", "1", "0",d)}'

do_install_append () {

    # Remove config files which have migrated to base
    # NOTE: runlevels are still managed by initscripts!
    rm ${D}${sysconfdir}/init.d/checkroot.sh
    rm ${D}${sysconfdir}/init.d/hostname.sh
    rm ${D}${sysconfdir}/init.d/populate-volatile.sh
    rm ${D}${sysconfdir}/init.d/read-only-rootfs-hook.sh
    rm ${D}${sysconfdir}/init.d/bootmisc.sh
    rm ${D}${sysconfdir}/logrotate-dmesg.conf

    # Sysfs.sh has been integrated in rcS
    update-rc.d -r ${D} -f sysfs.sh remove
    rm ${D}${sysconfdir}/init.d/sysfs.sh

    # Remove save-rtc.sh. We don't want to save timestamp on filesystem
    update-rc.d -r ${D} -f save-rtc.sh remove
    rm ${D}${sysconfdir}/init.d/save-rtc.sh

    if [ ${FB} != 0 ]; then
	update-rc.d -r ${D} -f alignment.sh remove
	update-rc.d -r ${D} alignment.sh start 20 5 .

	update-rc.d -r ${D} -f banner.sh remove
	update-rc.d -r ${D} banner.sh start 22 5 .

	update-rc.d -r ${D} -f dmesg.sh remove
	update-rc.d -r ${D} dmesg.sh start 30 5 .

	update-rc.d -r ${D} -f mountnfs.sh remove
	update-rc.d -r ${D} mountnfs.sh start 60 5 .

	update-rc.d -r ${D} -f urandom remove
	update-rc.d -r ${D} urandom start 65 5 0 6 .
    fi
    rm ${D}${sysconfdir}/init.d/urandom
}

