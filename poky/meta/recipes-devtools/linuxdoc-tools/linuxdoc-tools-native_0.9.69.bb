SUMMARY = "Convert LinuxDoc SGML source into other formats"
DESCRIPTION = "Convert LinuxDoc SGML source into other formats"
HOMEPAGE = "http://packages.debian.org/linuxdoc-tools"
LICENSE = "GPLv3+"
LIC_FILES_CHKSUM = "file://COPYING;md5=077ef64ec3ac257fb0d786531cf26931"

DEPENDS = "groff-native openjade-native"

PR = "r0"

SRC_URI = "${DEBIAN_MIRROR}/main/l/linuxdoc-tools/linuxdoc-tools_${PV}.orig.tar.gz \
           file://disable_sgml2rtf.patch \
           file://disable_txt_doc.patch \
           file://disable_tex_doc.patch \
           file://disable_dvips_doc.patch"

SRC_URI[md5sum] = "1d13d500918a7a145b0edc2f16f61dd1"
SRC_URI[sha256sum] = "7103facee18a2ea97186ca459d743d22f7f89ad4b5cd1dfd1c34f83d6bfd4101"

FILESPATH = "${FILE_DIRNAME}/linuxdoc-tools-native/"

inherit autotools native

do_configure () {
	oe_runconf
}
