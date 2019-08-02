FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PR := "${PR}.x1"

SRC_URI_append_us01-wu16 = " file://sysctl_wu16.conf "
do_install_append_wu16 () {
        install -d ${D}${sysconfdir}
        rm ${D}${sysconfdir}/sysctl.conf
        install -m 0644 ${WORKDIR}/sysctl_wu16.conf ${D}${sysconfdir}/sysctl.conf
}

# Use sysvinit pidof
base_bindir_progs_remove = "pidof"
