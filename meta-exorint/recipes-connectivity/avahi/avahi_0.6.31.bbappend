PR := "${PR}.x6"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:${THISDIR}/files:"

SRC_URI += "file://avoid-invalidresponsepacket-flood.patch"

do_install_append () {
    # Remove config files which have migrated to base
    rm -f ${D}${sysconfdir}/etc/avahi/avahi-autoipd.action
    rm -f ${D}${sysconfdir}/etc/udhcpc.d/*avahi-autoipd
}

# Init script is disabled by default
INITSCRIPT_PARAMS_avahi-daemon = "stop 20 0 1 6 ."
