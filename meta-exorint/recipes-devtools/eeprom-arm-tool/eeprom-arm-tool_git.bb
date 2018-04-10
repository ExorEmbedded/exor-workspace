DESCRIPTION = "eepromARMTool"
LICENSE = "GPL"
LIC_FILES_CHKSUM = "file://eepromARMTool/523420_NVM_ARM_Guide_Rev1.1_Final.pdf;md5=61539294e5abc65ee048eceaa10ae113"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

inherit exorint-src

PR = "r0"

SRCNAME = "ltools"
SRCREV = "f83978844d64b91c3cc85329cb72f0eee45941e8"
SRCBRANCH = "microsom-imx"

SRC_URI += "file://pciexpressmodel.hex"

SRC_URI[md5sum] = "55a12fcb5d3a7231c9850ef9d9f82918"
SRC_URI[sha256sum] = "8c50a74c07b1fffcbb20bd79e3ee92f1f52191e5a187433bb49964ccf94badb6"

FILES_${PN}= "${bindir}/eepromARMtool ${bindir}/pciexpressmodel.hex"

do_compile() {
	unset CC
	cd ${S}/eepromARMTool
	oe_runmake
}

do_install() {
	install -d ${D}/${bindir}
	install -m 0755 ${S}/eepromARMTool/eepromARMtool ${D}/${bindir}
	install -m 0644 ${WORKDIR}/pciexpressmodel.hex ${D}/${bindir}
}
