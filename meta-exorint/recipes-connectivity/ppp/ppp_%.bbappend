FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

PR := "${PR}.x6"

SRC_URI += "file://gprs.sh"
SRC_URI += "file://provider.sh"
SRC_URI += "file://secrets.sh"
SRC_URI += "file://05addgw"

RDEPENDS_${PN} += "bash"

do_install_append () {
	rm -f ${D}${sysconfdir}/chatscripts/gprs
	install -m 0755 ${WORKDIR}/gprs.sh ${D}${sysconfdir}/chatscripts/gprs.sh
	rm -f ${D}${sysconfdir}/ppp/peers/provider
	install -m 0755 ${WORKDIR}/provider.sh ${D}${sysconfdir}/ppp/peers/provider.sh
	rm -f ${D}${sysconfdir}/ppp/peers/*-secrets
	install -m 0755 ${WORKDIR}/secrets.sh ${D}${sysconfdir}/ppp/
	install -m 0755 ${WORKDIR}/05addgw ${D}${sysconfdir}/ppp/ip-up.d/
}
