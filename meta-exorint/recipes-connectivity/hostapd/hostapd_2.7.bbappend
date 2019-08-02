PR := "${PR}.x2"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:${THISDIR}/files:"

SRC_URI += "file://hostapd.sh"

# Install up script instead of init script
do_install_append () {

    install -d ${D}${sysconfdir}/network/if-pre-up.d/
    install -d ${D}${sysconfdir}/network/if-post-down.d/
    install -m 755 ${WORKDIR}/hostapd.sh ${D}${sysconfdir}/network/if-pre-up.d/hostapd
    cd ${D}${sysconfdir}/network/ && \
    ln -sf ../if-pre-up.d/hostapd if-post-down.d/hostapd

}

INITSCRIPT_PARAMS = "stop 20 0 1 6 ."
