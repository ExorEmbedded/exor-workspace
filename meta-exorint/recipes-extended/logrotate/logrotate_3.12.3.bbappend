PR := "${PR}.x1"

do_install_append () {
    # Remove config files which have migrated to base
    rm -f ${D}${sysconfdir}/logrotate-dmesg.conf
    rm -f ${D}${sysconfdir}/logrotate.conf

    mkdir -p ${D}${sysconfdir}/cron.minutely
    mv ${D}${sysconfdir}/cron.daily/logrotate ${D}${sysconfdir}/cron.minutely
}
