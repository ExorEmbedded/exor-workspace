PR := "${PR}.x2"

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:${THISDIR}/files:"

do_install_append () {
    # save original configuration so it can be restored upon reset
    cp ${D}${sysconfdir}/wpa_supplicant.conf ${D}${sysconfdir}/wpa_supplicant-default.conf
}
