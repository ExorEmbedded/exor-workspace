# Minimized vim without docs and data files

FILESEXTRAPATHS := "${THISDIR}/files"

SRC_URI += "file://vimrc"

PACKAGES =+ "${PN}-plugins ${PN}-lang"

FILES_${PN}-plugins = "${datadir}/${PN}/${VIMDIR}/ftplugin"

FILES_${PN}-lang = "${datadir}/${PN}/${VIMDIR}/lang"
FILES_${PN}-lang += "${datadir}/${PN}/${VIMDIR}/spell"

FILES_${PN}-data = "${datadir}/${PN}/${VIMDIR}/colors"
FILES_${PN}-data += "${datadir}/${PN}/${VIMDIR}/compiler"
FILES_${PN}-data += "${datadir}/${PN}/${VIMDIR}/indent"
FILES_${PN}-data += "${datadir}/${PN}/${VIMDIR}/macros"
FILES_${PN}-data += "${datadir}/${PN}/${VIMDIR}/print"
FILES_${PN}-data += "${datadir}/${PN}/${VIMDIR}/syntax"

RRECOMMENDS_${PN} = "${PN}-vimrc"

do_install_append() {

    install -m 0644 "${WORKDIR}/vimrc" "${D}/${datadir}/${PN}/"
}
