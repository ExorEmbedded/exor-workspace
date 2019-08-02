PR := "${PR}.x2"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:${THISDIR}/files:"

inherit gtk-doc gobject-introspection

SRC_URI += "file://avoid-invalidresponsepacket-flood.patch"
SRC_URI += "file://avahi-daemon.conf.sh"
SRC_URI += "file://initscript-gen-conf.patch"

FILES_avahi-daemon += "${sysconfdir}/avahi/avahi-daemon.conf.sh"

do_install_append () {

    install -d ${D}${sysconfdir}/avahi
    # conf generator script
    cp ${WORKDIR}/avahi-daemon.conf.sh ${D}${sysconfdir}/avahi/

    # Don't install default services
    rm -f ${D}${sysconfdir}/avahi/services/*.service

    # Remove config files which have migrated to base
    rm -f ${D}${sysconfdir}/avahi/avahi-autoipd.action
    rm -rf ${D}${sysconfdir}/udhcpc.d
}

# Init script is disabled by default
INITSCRIPT_PARAMS_avahi-daemon = "stop 4 ."

# Don't leave it too late because it's required by EPAD for Carel AP mode
INITSCRIPT_PARAMS_avahi-daemon_carel = "defaults 56 30"
