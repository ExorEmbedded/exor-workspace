DESCRIPTION = "PoDoFo is a library to work with the PDF file format"
HOMEPAGE = "http://podofo.sourceforge.net/"
LICENSE = "LGPLv3"
LIC_FILES_CHKSUM = "file://COPYING;md5=393a5ca445f6965873eca0259a17f833"

DEPENDS = "zlib freetype fontconfig openssl"

PR = "r1"
SRC_URI = "http://sourceforge.net/projects/podofo/files/podofo/${PV}/${PN}-${PV}.tar.gz/download;downloadfilename=${PN}-${PV}.tar.gz"

SRC_URI[md5sum] = "46336fc4c4ce4be814bb5fbb4d918334"

S = "${WORKDIR}/${PN}-${PV}"

inherit cmake pkgconfig

PACKAGES =+ "${PN}-sign"
FILES_${PN}-sign = "${bindir}/${PN}sign"
