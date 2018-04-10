# Based on poky version, adds:
#   - simple.script: default network configuration feature
#   - custom init order

FILESEXTRAPATHS_prepend := "${THISDIR}/files:${THISDIR}/${PN}-${PV}:"

PR := "${PR}.x20"

do_install_append () {
    # Remove config files which have migrated to base
    rm -f ${D}${sysconfdir}/udhcpc.d/50default
}

INITSCRIPT_PARAMS_${PN}-hwclock = "defaults 02 98"
INITSCRIPT_PARAMS_${PN}-syslog = "defaults 01 99"

# Customize boot order --> Fastboot
INITSCRIPT_PARAMS_${PN}-syslog_wu16 = "defaults 15 99"


